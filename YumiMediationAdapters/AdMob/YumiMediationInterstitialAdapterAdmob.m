//
//  YumiMediationInterstitialAdapterAdMob.m
//  Pods
//
//  Created by 魏晓磊 on 17/6/21.
//
//

#import "YumiMediationInterstitialAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationInterstitialAdapterAdMob ()

@property (nonatomic) GADInterstitial *interstitial;

@end

@implementation YumiMediationInterstitialAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:@"10002"
                                                             requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    if (!self.interstitial) {
        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.provider.data.key1];
        self.interstitial.delegate = self;
    }

    return self;
}

- (void)requestAd {
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
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
