//
//  YumiMediationBannerAdapterPlayableAds.m
//  Pods
//
//  Created by generator on 12/11/2019.
//
//

#import "YumiMediationBannerAdapterPlayableAds.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/AtmosplayAdsBanner.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/PlayableAdsGDPR.h>

@interface YumiMediationBannerAdapterPlayableAds () <YumiMediationBannerAdapter,AtmosplayAdsBannerDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;
@property (nonatomic)AtmosplayAdsBanner *banner;

@end

@implementation YumiMediationBannerAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDPlayableAds
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (NSString *)networkVersion {
    @"2.6.0";
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self didFailToReceiveAd:@"ZplayAds not support kYumiMediationAdViewBanner300x250"];
          return;
    }
    
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusPersonalized];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
         [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusNonPersonalized];
    }
    
    self.banner = [[AtmosplayAdsBanner alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1 rootViewController:[self.delegate rootViewControllerForPresentingModalView]];
    
    AtmosplayAdsBannerSize bannerSize = isiPad ? kAtmosplayAdsBanner728x90 :kAtmosplayAdsBanner320x50;
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait) {
        bannerSize = kAtmosplayAdsSmartBannerPortrait;
    }
    if (self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        bannerSize = kAtmosplayAdsSmartBannerLandscape;
    }
    
    self.banner.bannerSize  = bannerSize;
    self.banner.delegate = self;
    [self.banner loadAd];
}

#pragma mark: AtmosplayAdsBannerDelegate
- (void)atmosplayAdsBannerViewDidLoad:(AtmosplayAdsBanner *)bannerView {
   [self.delegate adapter:self didReceiveAd:bannerView];
}
/// Tells the delegate that a request failed.
- (void)atmosplayAdsBannerView:(AtmosplayAdsBanner *)bannerView didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

/// Tells the delegate that the banner view has been clicked.
- (void)atmosplayAdsBannerViewDidClick:(AtmosplayAdsBanner *)bannerView {
    [self.delegate adapter:self didClick:bannerView];
}

@end
