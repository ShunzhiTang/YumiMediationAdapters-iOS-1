//
//  YumiMediationInterstitialAdapterGDT.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterGDT.h"
#import "GDTUnifiedInterstitialAd.h"

@interface YumiMediationInterstitialAdapterGDT () <GDTUnifiedInterstitialAdDelegate>

@property (nonatomic) GDTUnifiedInterstitialAd *interstitial;

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

    return self;
}

- (void)requestAd {
    if (self.interstitial) {
        self.interstitial.delegate = nil;
    }
    self.interstitial = [[GDTUnifiedInterstitialAd alloc] initWithAppId:self.provider.data.key1 ?: @""
                                                            placementId:self.provider.data.key2 ?: @""];
    self.interstitial.delegate = self;
    
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    return [self.interstitial isAdValid];
}

- (void)present {
    [self.interstitial presentAdFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - GDTUnifiedInterstitialAdDelegate
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate adapter:self didReceiveInterstitialAd:unifiedInterstitial];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
   [self.delegate adapter:self interstitialAd:unifiedInterstitial didFailToReceive:[error localizedDescription]];
}

- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
   [self.delegate adapter:self willPresentScreen:unifiedInterstitial];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
   [self.delegate adapter:self didClickInterstitialAd:unifiedInterstitial];
}

- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate adapter:self willDismissScreen:unifiedInterstitial];
}


@end
