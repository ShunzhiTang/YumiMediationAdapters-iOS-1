//
//  YumiMediationInterstitialAdapterNativeAdMob.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import "YumiMediationInterstitialAdapterNativeAdMob.h"
#import <GoogleMobileAds/GADNativeAdViewAdOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeAdMob () <GADNativeAppInstallAdLoaderDelegate, GADAdLoaderDelegate,
                                                           GADNativeAdDelegate>

@property (nonatomic) GADAdLoader *adLoader;
@property (nonatomic) GADNativeAppInstallAdView *appInstallAdView;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterNativeAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDAdmobNative
                                                             requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark : - private method
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
    self.isAdReady = NO;

    [self.appInstallAdView removeFromSuperview];
    [self.delegate coreAdapter:self didCloseCoreAd:self.appInstallAdView isCompletePlaying:NO adType:self.adType];
}

#pragma mark : YumiMediationInterstitialAdapter

- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType{
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GADNativeAdViewAdOptions *option = [[GADNativeAdViewAdOptions alloc] init];
        option.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
        NSMutableArray *adTypes = [[NSMutableArray alloc] init];
        [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];

        weakSelf.adLoader =
            [[GADAdLoader alloc] initWithAdUnitID:weakSelf.provider.data.key1
                               rootViewController:[[YumiTool sharedTool] topMostController]
                                          adTypes:adTypes
                                          options:@[ option ]];

        GADRequest *request = [GADRequest request];

        weakSelf.adLoader.delegate = weakSelf;
        [weakSelf.adLoader loadRequest:request];
    });
}

- (BOOL)isReady {

    return self.isAdReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[[YumiTool sharedTool] topMostController].view addSubview:self.appInstallAdView];
}

#pragma mark : - GADAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    self.isAdReady = NO;

    [self.delegate coreAdapter:self coreAd:adLoader didFailToLoad:[error localizedDescription] adType:self.adType];
}

#pragma mark : - GADNativeAppInstallAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    self.isAdReady = YES;

    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"YumiMediationAdMob" withExtension:@"bundle"];
    NSBundle *YumiMediationAdMob = [NSBundle bundleWithURL:bundleURL];

    if ([[YumiTool sharedTool] isInterfaceOrientationPortrait]) {
        self.self.appInstallAdView =
            [YumiMediationAdMob loadNibNamed:@"AdmobNativeInstallAdView" owner:nil options:nil].firstObject;
    } else {
        self.appInstallAdView =
            [YumiMediationAdMob loadNibNamed:@"AdmobNativeInstallAdView_Lan" owner:nil options:nil].firstObject;
    }

    self.appInstallAdView.frame = [UIScreen mainScreen].bounds;
    nativeAppInstallAd.delegate = self;
    self.appInstallAdView.nativeAppInstallAd = nativeAppInstallAd;

    // close button
    UIButton *closeBtn = (UIButton *)[self.appInstallAdView viewWithTag:120];
    [closeBtn addTarget:self action:@selector(closeIntersitital) forControlEvents:UIControlEventTouchUpInside];

    UIButton *clickBtn = (UIButton *)[self.appInstallAdView viewWithTag:110];
    clickBtn.layer.cornerRadius = 5;
    clickBtn.layer.masksToBounds = YES;

    ((UILabel *)self.appInstallAdView.headlineView).text = nativeAppInstallAd.headline;
    ((UILabel *)self.appInstallAdView.headlineView).font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];

    ((UIImageView *)self.appInstallAdView.iconView).image = nativeAppInstallAd.icon.image;

    ((UIImageView *)self.appInstallAdView.iconView).layer.cornerRadius = 10;
    ((UIImageView *)self.appInstallAdView.iconView).layer.masksToBounds = YES;
    ((UILabel *)self.appInstallAdView.bodyView).text = nativeAppInstallAd.body;
    [((UIButton *)self.appInstallAdView.callToActionView) setTitle:@"" forState:UIControlStateNormal];

    if (nativeAppInstallAd.starRating) {
        ((UIImageView *)self.appInstallAdView.starRatingView).image =
            [self imageForStars:nativeAppInstallAd.starRating];
        self.appInstallAdView.starRatingView.hidden = NO;
    } else {
        self.appInstallAdView.starRatingView.hidden = YES;
    }

    if (nativeAppInstallAd.price) {
        ((UILabel *)self.appInstallAdView.priceView).text = nativeAppInstallAd.price;
        self.appInstallAdView.priceView.hidden = NO;
    } else {
        self.appInstallAdView.priceView.hidden = YES;
    }

    [self.delegate coreAdapter:self didReceivedCoreAd:self.appInstallAdView adType:self.adType];
}

#pragma mark : - GADNativeAdDelegate
- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    [self.delegate coreAdapter:self didOpenCoreAd:self.appInstallAdView adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.appInstallAdView adType:self.adType];
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
    [self.delegate coreAdapter:self didClickCoreAd:self.appInstallAdView adType:self.adType];
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
    [self closeIntersitital];
}

@end
