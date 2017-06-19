//
//  AdsYuMIAdNetworkFacebookAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/21.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkFacebookAdapter.h"

@implementation AdsYuMIAdNetworkFacebookAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdFacebook;
}

+ (void)load {
    //[[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    FBAdSize adSize = kFBAdSize320x50;

    switch (self.adType) {
        case AdViewYMTypeNormalBanner:
        case AdViewYMTypeiPadNormalBanner:
            adSize = kFBAdSizeHeight50Banner;
            break;
        case AdViewYMTypeRectangle:
            adSize = kFBAdSizeHeight250Rectangle;
            break;
        case AdViewYMTypeMediumBanner:
            adSize = kFBAdSizeInterstitial;
            break;
        case AdViewYMTypeLargeBanner:
            adSize = kFBAdSizeHeight90Banner;
            break;
        default:
            [self adapter:self didFailAd:nil];
            break;
    }

    if (self.IsAutoAdSize) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            adSize = kFBAdSizeHeight90Banner;
        } else {
            adSize = kFBAdSizeHeight50Banner;
        }
    }

    [self adDidStartRequestAd];

    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:8
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }

    self.fbView =
        [[FBAdView alloc] initWithPlacementID:self.provider.key1
                                       adSize:adSize
                           rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
    // Set a delegate to get notified on changes or when the user interact with the ad.
    self.fbView.delegate = self;
    [self.fbView loadAd];
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    self.fbView.frame = CGRectMake(0, 0, viewSize.width, adSize.size.height);
    self.adNetworkView = self.fbView;
}

- (void)stopAd {
    isStop = YES;
    [self stopTimer];
}

- (void)timeOutTimer {

    if (isStop || isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[FBAdView class]]) {
        [(FBAdView *)self.adNetworkView setDelegate:nil];
    }
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Facebook time out"]];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark facebook Delegate

- (void)adViewDidClick:(FBAdView *)adView {
    [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

- (void)adViewDidLoad:(FBAdView *)adView {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Facebook no ad"]];
    adView.delegate = nil;
}

- (UIViewController *)viewControllerForPresentingModalView {
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (void)dealloc {
    FBAdView *_adView = (FBAdView *)self.adNetworkView;
    if (_adView != nil) {
        _adView.delegate = nil;
    }
}
@end
