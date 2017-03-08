//
//  AdsYUMISample
//
//  Created by Liubin on 16/6/6.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkNativeInterstitalGoogleAdapter.h"
#import <GoogleMobileAds/GADNativeAdViewAdOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdsYuMIAdNetworkNativeInterstitalGoogleAdapter () <GADNativeAppInstallAdLoaderDelegate,
                                                              GADNativeAdDelegate> {

    NSTimer *timer;
    BOOL isReading;
    GADNativeAppInstallAdView *appInstallAdView;
    BOOL isHidden;
}

@property (nonatomic, strong) GADAdLoader *adLoader;

@end

@implementation AdsYuMIAdNetworkNativeInterstitalGoogleAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdAdmobNative;
}

+ (void)load {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
    }
}

- (void)getAd {

    isReading = NO;
    isHidden = NO;
    [self adapterDidStartInterstitialRequestAd];

    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }

    GADNativeAdViewAdOptions *option = [[GADNativeAdViewAdOptions alloc] init];
    option.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;

    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:self.provider.key1
                                       rootViewController:[self viewControllerForWillPresentInterstitialModalView]
                                                  adTypes:adTypes
                                                  options:@[ option ]];

    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}

- (void)stopAd {
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)timeOutTimer {
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Admob native time out"]];
}

//是否自动发送统计
- (BOOL)isAutoStatistical {
    return NO;
}

#pragma mark GADAdLoaderDelegate implementation
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Admob native no ad"]];
}

#pragma mark GADNativeAppInstallAdLoaderDelegate implementation
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];

    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ||
        [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        appInstallAdView =
            [[NSBundle mainBundle] loadNibNamed:@"AdmobNativeInstallAdView" owner:nil options:nil].firstObject;
    } else {
        appInstallAdView =
            [[NSBundle mainBundle] loadNibNamed:@"AdmobNativeInstallAdView_Lan" owner:nil options:nil].firstObject;
    }

    appInstallAdView.frame = [UIScreen mainScreen].bounds;
    nativeAppInstallAd.delegate = self;
    appInstallAdView.nativeAppInstallAd = nativeAppInstallAd;

    //设置关闭按钮
    UIButton *closeBtn = (UIButton *)[appInstallAdView viewWithTag:120];
    [closeBtn addTarget:self action:@selector(closeIntersitital) forControlEvents:UIControlEventTouchUpInside];

    UIButton *clickBtn = (UIButton *)[appInstallAdView viewWithTag:110];
    clickBtn.layer.cornerRadius = 5;
    clickBtn.layer.masksToBounds = YES;

    ((UILabel *)appInstallAdView.headlineView).text = nativeAppInstallAd.headline;
    ((UILabel *)appInstallAdView.headlineView).font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];

    ((UIImageView *)appInstallAdView.iconView).image = nativeAppInstallAd.icon.image;

    ((UIImageView *)appInstallAdView.iconView).layer.cornerRadius = 10;
    ((UIImageView *)appInstallAdView.iconView).layer.masksToBounds = YES;
    ((UILabel *)appInstallAdView.bodyView).text = nativeAppInstallAd.body;
    [((UIButton *)appInstallAdView.callToActionView) setTitle:@"" forState:UIControlStateNormal];

    if (nativeAppInstallAd.starRating) {
        ((UIImageView *)appInstallAdView.starRatingView).image = [self imageForStars:nativeAppInstallAd.starRating];
        appInstallAdView.starRatingView.hidden = NO;
    } else {
        appInstallAdView.starRatingView.hidden = YES;
    }

    if (nativeAppInstallAd.price) {
        ((UILabel *)appInstallAdView.priceView).text = nativeAppInstallAd.price;
        appInstallAdView.priceView.hidden = NO;
    } else {
        appInstallAdView.priceView.hidden = YES;
    }

    [self adapterDidInterstitialReceiveAd:self];
}

- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
    double starRating = numberOfStars.doubleValue;
    if (starRating >= 5) {
        return [UIImage imageNamed:@"stars_5"];
    } else if (starRating >= 4.5) {
        return [UIImage imageNamed:@"stars_4_5"];
    } else if (starRating >= 4) {
        return [UIImage imageNamed:@"stars_4"];
    } else {
        return [UIImage imageNamed:@"stars_3_5"];
    }
}

- (void)closeIntersitital {
    if (isHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [appInstallAdView removeFromSuperview];
    [self adapterInterstitialDidDismissScreen:self];
}

- (void)preasentInterstitial {
    if (![UIApplication sharedApplication].statusBarHidden) {
        isHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [[self viewControllerForWillPresentInterstitialModalView].view addSubview:appInstallAdView];
    [self adapterInterstitialDidPresentScreen:self];
}

- (void)dismissInterstital {
    [self adapterInterstitialDidDismissScreen:self];
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

- (void)dealloc {
    [self stopTimer];
    appInstallAdView = nil;
    _adLoader = nil;
}

@end
