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

@interface YumiMediationBannerAdapterApplovin () <YumiMediationBannerAdapter, ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) ALAdView *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterApplovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAppLovin
                                                       requestType:YumiMediationSDKAdRequest];
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
    
    ALAdSize *adSize = isiPad ? [ALAdSize sizeLeader] : [ALAdSize sizeBanner];
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = [ALAdSize sizeMRec];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.bannerView = [[ALAdView alloc] initWithSize:adSize zoneIdentifier:weakSelf.provider.data.key2];
        weakSelf.bannerView.adLoadDelegate = weakSelf;
        weakSelf.bannerView.adDisplayDelegate = weakSelf;
        weakSelf.bannerView.autoload = NO;
        [weakSelf.bannerView loadNextAd];
    });
}
#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [self.delegate adapter:self didReceiveAd:self.bannerView];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
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
