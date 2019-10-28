//
//  YumiMediationBannerAdapterApplovin.m
//  Pods
//
//  Created by shunzhiTang 21/6/2018.
//
//

#import "YumiMediationBannerAdapterApplovin.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterApplovin () <YumiMediationBannerAdapter, ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) ALAdView *bannerView;
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterApplovin
- (NSString *)networkVersion {
    return @"6.9.4";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAppLovin
                                                       requestType:YumiMediationSDKAdRequest];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:YumiMediationApplovinAdapterUUID];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if (self.provider.data.key2.length == 0) {
        [self.delegate adapter:self didFailToReceiveAd:@"No zone identifier specified"];
        return;
    }
    // set adFrame
    CGRect adframe = isiPad ? CGRectMake(0, 0, 728, 90) : CGRectMake(0, 0, 320, 50);
    if (self.isSmartBanner) {
        CGSize size = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
        adframe = CGRectMake(0, 0, size.width, size.height);
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adframe = CGRectMake(0, 0, 300, 250);
    }
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"applovin not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [ALPrivacySettings setHasUserConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [ALPrivacySettings setHasUserConsent:NO];
    }
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationApplovinAdapterUUID]) {
        [[YumiLogger stdLogger] debug:@"---Applovin start request"];
        weakSelf.bannerView = [[ALAdView alloc] initWithSize:ALAdSize.banner zoneIdentifier:weakSelf.provider.data.key2];
        // Optional: Implement the ad delegates to receive ad events.
        self.bannerView.adLoadDelegate = self;
        self.bannerView.adDisplayDelegate = self;
        self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        // Call loadNextAd() to start showing ads
        [self.bannerView loadNextAd];
        return;
    }
    [[YumiLogger stdLogger] debug:@"---Applovin start init"];
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration * _Nonnull configuration) {
        [[YumiLogger stdLogger] debug:@"---Applovin is configured"];
        [standardUserDefaults setObject:@"Applovin_is_starting" forKey:YumiMediationApplovinAdapterUUID];
        [standardUserDefaults synchronize];
        [[YumiLogger stdLogger] debug:@"---Applovin start request"];
        weakSelf.bannerView = [[ALAdView alloc] initWithSize:ALAdSize.banner zoneIdentifier:weakSelf.provider.data.key2];
        // Optional: Implement the ad delegates to receive ad events.
        weakSelf.bannerView.adLoadDelegate = self;
        weakSelf.bannerView.adDisplayDelegate = self;
        weakSelf.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        // Call loadNextAd() to start showing ads
        [weakSelf.bannerView loadNextAd];
    }];
    // set refresh state
    if (weakSelf.provider.data.autoRefreshInterval == 0) {
        weakSelf.bannerView.autoload = NO;
    } else {
        weakSelf.bannerView.autoload = YES;
    }
}
#pragma mark - Ad Load Delegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [[YumiLogger stdLogger] debug:@"---Applovin did load"];
    [self.delegate adapter:self didReceiveAd:self.bannerView];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    [[YumiLogger stdLogger] debug:@"---Applovin did fail to load"];
    NSString *error = [NSString stringWithFormat:@"Applovin error code is %d", code];
    [self.delegate adapter:self didFailToReceiveAd:error];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self.delegate adapter:self didClick:self.bannerView];
}

@end
