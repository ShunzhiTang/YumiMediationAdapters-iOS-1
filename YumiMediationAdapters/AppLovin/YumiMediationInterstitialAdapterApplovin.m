//
//  YumiMediationInterstitialAdapterApplovin.m
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import "YumiMediationInterstitialAdapterApplovin.h"
#import <AppLovinSDK/ALInterstitialAd.h>

@interface YumiMediationInterstitialAdapterApplovin () <ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic) ALInterstitialAd *interstitial;
@property (nonatomic) ALAd *ad;
@property (nonatomic) ALSdk *sdk;
@property (nonatomic, assign) BOOL isAdReady;

@end

@implementation YumiMediationInterstitialAdapterApplovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDAppLovin
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.sdk = [ALSdk sharedWithKey:self.provider.data.key1];

    self.interstitial = [[ALInterstitialAd alloc] initWithSdk:self.sdk];
    self.interstitial.adDisplayDelegate = self;

    return self;
}

- (void)requestAd {
    if (self.provider.data.key2.length == 0) {
        [self.delegate adapter:self interstitialAd:nil didFailToReceive:@"No zone identifier specified"];
        return;
    }
    self.isAdReady = NO;
    [[self.sdk adService] loadNextAdForZoneIdentifier:self.provider.data.key2 andNotify:self];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)present {
    [self.interstitial showOver:[UIApplication sharedApplication].keyWindow andRender:self.ad];
}

#pragma mark - Ad Load Delegate
- (void)adService:(nonnull ALAdService *)adService didLoadAd:(nonnull ALAd *)ad {
    self.ad = ad;
    self.isAdReady = YES;
    [self.delegate adapter:self didReceiveInterstitialAd:ad];
}

- (void)adService:(nonnull ALAdService *)adService didFailToLoadAdWithError:(int)code {
    [self.delegate adapter:self
            interstitialAd:nil
          didFailToReceive:[NSString stringWithFormat:@"applovin error code:%d", code]];
}

#pragma mark - Ad Display Delegate
- (void)ad:(nonnull ALAd *)ad wasDisplayedIn:(nonnull UIView *)view {
    [self.delegate adapter:self willPresentScreen:ad];
}

- (void)ad:(nonnull ALAd *)ad wasHiddenIn:(nonnull UIView *)view {
    [self.delegate adapter:self willDismissScreen:ad];
}

- (void)ad:(nonnull ALAd *)ad wasClickedIn:(nonnull UIView *)view {
    [self.delegate adapter:self didClickInterstitialAd:ad];
}

@end
