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
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeAdMob () <GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate,
                                                           GADUnifiedNativeAdDelegate>

@property (nonatomic) GADAdLoader *adLoader;
@property (nonatomic) GADUnifiedNativeAdView *appInstallAdView;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterNativeAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAdmobNative
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:YumiMediationAdmobAdapterUUID];
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
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        return self;
    }
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
    }];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString*)networkVersion {
    return @"7.44.0";
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GADNativeAdViewAdOptions *option = [[GADNativeAdViewAdOptions alloc] init];
        option.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
        NSMutableArray *adTypes = [[NSMutableArray alloc] init];
        [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];

        weakSelf.adLoader = [[GADAdLoader alloc] initWithAdUnitID:weakSelf.provider.data.key1
                                               rootViewController:[[YumiTool sharedTool] topMostController]
                                                          adTypes:adTypes
                                                          options:@[ option ]];

        // set GDPR
        YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

        GADExtras *extras = [[GADExtras alloc] init];
        if (gdprStatus == YumiMediationConsentStatusPersonalized) {
            extras.additionalParameters = @{@"npa" : @"0"};
        }
        if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
            extras.additionalParameters = @{@"npa" : @"1"};
        }

        GADRequest *request = [GADRequest request];
        [request registerAdNetworkExtras:extras];

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

#pragma mark : - GADUnifiedNativeAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
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
    nativeAd.delegate = self;
    self.appInstallAdView.nativeAd = nativeAd;

    // close button
    UIButton *closeBtn = (UIButton *)[self.appInstallAdView viewWithTag:120];
    [closeBtn addTarget:self action:@selector(closeIntersitital) forControlEvents:UIControlEventTouchUpInside];

    UIButton *clickBtn = (UIButton *)[self.appInstallAdView viewWithTag:110];
    clickBtn.layer.cornerRadius = 5;
    clickBtn.layer.masksToBounds = YES;

    ((UILabel *)self.appInstallAdView.headlineView).text = nativeAd.headline;
    ((UILabel *)self.appInstallAdView.headlineView).font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];

    ((UIImageView *)self.appInstallAdView.iconView).image = nativeAd.icon.image;

    ((UIImageView *)self.appInstallAdView.iconView).layer.cornerRadius = 10;
    ((UIImageView *)self.appInstallAdView.iconView).layer.masksToBounds = YES;
    ((UILabel *)self.appInstallAdView.bodyView).text = nativeAd.body;
    [((UIButton *)self.appInstallAdView.callToActionView) setTitle:@"" forState:UIControlStateNormal];

    if (nativeAd.starRating) {
        ((UIImageView *)self.appInstallAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
        self.appInstallAdView.starRatingView.hidden = NO;
    } else {
        self.appInstallAdView.starRatingView.hidden = YES;
    }

    if (nativeAd.price) {
        ((UILabel *)self.appInstallAdView.priceView).text = nativeAd.price;
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
- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
    [self closeIntersitital];
}

@end
