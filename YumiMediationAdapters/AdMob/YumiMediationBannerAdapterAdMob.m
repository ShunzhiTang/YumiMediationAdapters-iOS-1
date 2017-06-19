//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterAdMob.h"
#import "YumiMediationAdapterRegistry.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationBannerAdapterAdMob () <GADBannerViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GADBannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10002"
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    GADAdSize adSize = isiPad ? kGADAdSizeLeaderboard : kGADAdSizeBanner;
    adSize = isPortrait ? kGADAdSizeSmartBannerPortrait : adSize;

    dispatch_async(dispatch_get_main_queue(), ^{
        GADRequest *request = [GADRequest request];
        self.bannerView.adSize = adSize;
        [self.bannerView loadRequest:request];
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

#pragma mark - Getters
- (GADBannerView *)bannerView {
    if (!_bannerView) {
        // TODO: set size, ad unit id ... according to provider property
        _bannerView = [[GADBannerView alloc] init];
        _bannerView.adUnitID = self.provider.data.key1;
        _bannerView.delegate = self;
        _bannerView.rootViewController = [self.delegate rootViewControllerForPresentingBannerView];
    }

    return _bannerView;
}

@end
