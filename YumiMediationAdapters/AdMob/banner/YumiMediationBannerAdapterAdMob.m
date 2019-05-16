//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterAdMob () <GADBannerViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GADBannerView *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAdMob
                                                       requestType:YumiMediationSDKAdRequest];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:YumiMediationAdmobAdapterUUID];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

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

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // set adSize
    GADAdSize adSize = isiPad ? kGADAdSizeLeaderboard : kGADAdSizeBanner;
    if (self.isSmartBanner) {
        adSize = isPortrait ? kGADAdSizeSmartBannerPortrait : kGADAdSizeSmartBannerLandscape;
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = kGADAdSizeMediumRectangle;
    }
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait) {
        adSize = kGADAdSizeSmartBannerPortrait;
    }
    if (self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        adSize = kGADAdSizeSmartBannerLandscape;
    }

    // set GDPR
    BOOL gdprStatus = [[YumiMediationGDPRManager sharedGDPRManager] getConsentStatus];
    GADRequest *request = [GADRequest request];
    GADExtras *extras = [[GADExtras alloc] init];
    if (gdprStatus) {
        extras.additionalParameters = @{@"npa": @"1"};
    }
    if (!gdprStatus) {
        extras.additionalParameters = @{@"npa": @"0"};
    }
    [request registerAdNetworkExtras:extras];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        strongSelf.bannerView.adUnitID = strongSelf.provider.data.key1;
        strongSelf.bannerView.delegate = strongSelf;
        strongSelf.bannerView.rootViewController = [strongSelf.delegate rootViewControllerForPresentingModalView];
        
        [strongSelf.bannerView loadRequest:request];
    });
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self.delegate adapter:self didReceiveAd:bannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    [self.delegate adapter:self didClick:bannerView];
}

@end
