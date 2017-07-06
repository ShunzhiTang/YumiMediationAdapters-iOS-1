//
//  YumiMediationInterstitialAdapterAdMob.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationInterstitialAdapterAdMob () <GADInterstitialDelegate>

@property (nonatomic) GADInterstitial *interstitial;

@end

@implementation YumiMediationInterstitialAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDAdMob
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.provider.data.key1];
    self.interstitial.delegate = self;

    return self;
}

- (void)requestAd {
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self.delegate adapter:self didReceiveInterstitialAd:ad];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate adapter:self interstitialAd:ad didFailToReceive:[error localizedDescription]];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [self.delegate adapter:self willDismissScreen:ad];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self.delegate adapter:self didClickInterstitialAd:ad];
}

@end
