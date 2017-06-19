//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterAdMob.h"
#import "YumiMediationAdapterConstructorRegistry.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation YumiMediationBannerAdapterAdMobConstructor

+ (void)load {
    [[YumiMediationAdapterConstructorRegistry registry] registerBannerAdapterConstructor:[self new]
                                                                           forProviderID:@"10002"
                                                                             requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)createAdapterWithProvider:(YumiMediationBannerProvider *)provider
                                                   delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    return [[YumiMediationBannerAdapterAdMob alloc] initWithYumiMediationAdProvider:provider delegate:delegate];
}

@end

@interface YumiMediationBannerAdapterAdMob () <GADBannerViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GADBannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterAdMob

- (instancetype)initWithYumiMediationAdProvider:(YumiMediationBannerProvider *)provider
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
