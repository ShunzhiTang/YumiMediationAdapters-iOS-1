//
//  YumiMediationInterstitialAdapterGDT.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterGDT.h"
#import "GDTMobInterstitial.h"

@interface YumiMediationInterstitialAdapterGDT () <GDTMobInterstitialDelegate>

@property (nonatomic) GDTMobInterstitial *interstitial;

@end

@implementation YumiMediationInterstitialAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDGDT
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.interstitial =
        [[GDTMobInterstitial alloc] initWithAppkey:self.provider.data.key1 placementId:self.provider.data.key2];
    self.interstitial.delegate = self;

    return self;
}

- (void)requestAd {
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - GDTMobInterstitialDelegate
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitial];
}

- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error {
    [self.delegate adapter:self interstitialAd:interstitial didFailToReceive:[error localizedDescription]];
}

- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial {
    [self.delegate adapter:self willPresentScreen:interstitial];
}

- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial {
    [self.delegate adapter:self willDismissScreen:interstitial];
}

- (void)interstitialClicked:(GDTMobInterstitial *)interstitial {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

@end
