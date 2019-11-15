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
    return  @"2.6.0";
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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YumiLogger stdLogger] debug:@"---Atmosplay Banner start request"];
        weakSelf.banner = [[AtmosplayAdsBanner alloc] initWithAdUnitID:weakSelf.provider.data.key2 appID:weakSelf.provider.data.key1 rootViewController:[weakSelf.delegate rootViewControllerForPresentingModalView]];
        
        AtmosplayAdsBannerSize bannerSize = isiPad ? kAtmosplayAdsBanner728x90 :kAtmosplayAdsBanner320x50;
        if (weakSelf.bannerSize == kYumiMediationAdViewSmartBannerPortrait) {
            bannerSize = kAtmosplayAdsSmartBannerPortrait;
        }
        if (weakSelf.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
            bannerSize = kAtmosplayAdsSmartBannerLandscape;
        }
        
        weakSelf.banner.bannerSize  = bannerSize;
        weakSelf.banner.delegate = weakSelf;
        [weakSelf.banner loadAd];
    });
    
}

#pragma mark: AtmosplayAdsBannerDelegate
- (void)atmosplayAdsBannerViewDidLoad:(AtmosplayAdsBanner *)bannerView {
   [self.delegate adapter:self didReceiveAd:bannerView];
    [[YumiLogger stdLogger] debug:@"---Atmosplay Banner did received"];
}
/// Tells the delegate that a request failed.
- (void)atmosplayAdsBannerView:(AtmosplayAdsBanner *)bannerView didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
    [[YumiLogger stdLogger] debug:@"---Atmosplay Banner did fail to load"];
}

/// Tells the delegate that the banner view has been clicked.
- (void)atmosplayAdsBannerViewDidClick:(AtmosplayAdsBanner *)bannerView {
    [self.delegate adapter:self didClick:bannerView];
    [[YumiLogger stdLogger] debug:@"---Atmosplay Banner did click"];
}

@end
