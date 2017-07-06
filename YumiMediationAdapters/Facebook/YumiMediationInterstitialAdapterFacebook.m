//
//  YumiMediationInterstitialAdapterFacebook.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterFacebook.h"
#import <FBAudienceNetwork/FBInterstitialAd.h>

@interface YumiMediationInterstitialAdapterFacebook () <FBInterstitialAdDelegate>

@property (nonatomic) FBInterstitialAd *interstitial;

@end

@implementation YumiMediationInterstitialAdapterFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebook
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.provider.data.key1];
    self.interstitial.delegate = self;

    return self;
}

- (void)requestAd {
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    return self.interstitial.adValid;
}

- (void)present {
    [self.interstitial showAdFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:interstitialAd didFailToReceive:[error localizedDescription]];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didClickInterstitialAd:interstitialAd];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self willDismissScreen:interstitialAd];
}

@end
