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

@interface YumiMediationBannerAdapterAdMob () <GADBannerViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GADBannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAdMob
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

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:autoAdSize] boolValue]) {
        adSize = isPortrait ? kGADAdSizeSmartBannerPortrait : kGADAdSizeSmartBannerLandscape;
    }

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:YumiMediationBannerSelectableAdSize] integerValue] ==
        kYumiMediationAdViewBanner300x250) {
        adSize = kGADAdSizeMediumRectangle;
    }

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

        GADRequest *request = [GADRequest request];
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
