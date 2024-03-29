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
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterNativeAdMob () <GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate,
                                                           GADUnifiedNativeAdDelegate>

@property (nonatomic) GADAdLoader *adLoader;
@property (nonatomic) GADUnifiedNativeAdView *appInstallAdView;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic) UIViewController *presentController;

@end

@implementation YumiMediationInterstitialAdapterNativeAdMob
- (NSString *)networkVersion {
    return @"7.50.0";
}

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
    [self.presentController dismissViewControllerAnimated:NO completion:^{
        [self.appInstallAdView removeFromSuperview];
    }];
    [[YumiLogger stdLogger] debug:@"---Admob is closed"];
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

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        [self requestAdmobNativeAd];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [[YumiLogger stdLogger] debug:@"---Admob init"];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [[YumiLogger stdLogger] debug:@"---Admob configured"];
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
        [weakSelf requestAdmobNativeAd];
    }];
}

- (void)requestAdmobNativeAd {
    [[YumiLogger stdLogger] debug:@"---Admob start request"];
    self.presentController = [[UIViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GADNativeAdViewAdOptions *option = [[GADNativeAdViewAdOptions alloc] init];
        option.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
        NSMutableArray *adTypes = [[NSMutableArray alloc] init];
        [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];

        weakSelf.adLoader = [[GADAdLoader alloc] initWithAdUnitID:weakSelf.provider.data.key1
                                               rootViewController:weakSelf.presentController
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
    [[YumiLogger stdLogger] debug:@"---Admob present"];
    self.presentController.view.backgroundColor = [UIColor blackColor];
    [self.presentController.view addSubview:self.appInstallAdView];
    self.presentController.modalPresentationStyle = UIModalPresentationFullScreen;
    [rootViewController presentViewController:self.presentController animated:NO completion:nil];
}

#pragma mark : - GADAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    [[YumiLogger stdLogger] debug:@"---Admob did fail to load"];
    self.isAdReady = NO;
    [self.delegate coreAdapter:self coreAd:adLoader didFailToLoad:[error localizedDescription] adType:self.adType];
}

#pragma mark : - GADUnifiedNativeAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
    self.isAdReady = YES;

    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"YumiMediationAdMob" withExtension:@"bundle"];
    NSBundle *YumiMediationAdMob = [NSBundle bundleWithURL:bundleURL];
    
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = UIScreen.mainScreen.bounds.size.height;
    if ([[YumiTool sharedTool] isInterfaceOrientationPortrait]) {
        self.self.appInstallAdView =
            [YumiMediationAdMob loadNibNamed:@"AdmobNativeInstallAdView" owner:nil options:nil].firstObject;
        h = h-100;
    } else {
        w = UIScreen.mainScreen.bounds.size.width-100;
        self.appInstallAdView =
            [YumiMediationAdMob loadNibNamed:@"AdmobNativeInstallAdView_Lan" owner:nil options:nil].firstObject;
    }
    
    self.appInstallAdView.frame = CGRectMake(0, 0, w, h);
    self.appInstallAdView.center = [[YumiTool sharedTool] topMostController].view.center;
    
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
    [[YumiLogger stdLogger] debug:@"---Admob did load"];
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
