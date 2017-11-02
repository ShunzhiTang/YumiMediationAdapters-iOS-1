//
//  YumiMediationInterstitialAdapterTouTiao.m
//  Pods
//
//  Created by generator on 02/11/2017.
//
//

#import "YumiMediationInterstitialAdapterTouTiao.h"
#import <WMAdSDK/WMAdSDKManager.h>
#import <WMAdSDK/WMInterstitialAd.h>
#import <WMAdSDK/WMSize.h>

@interface YumiMediationInterstitialAdapterTouTiao () <WMInterstitialAdDelegate>

@property (nonatomic) WMInterstitialAd *interstitial;

@end

@implementation YumiMediationInterstitialAdapterTouTiao

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDYumiAds
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    [WMAdSDKManager setAppID:self.provider.data.key1];

    return self;
}

- (void)requestAd {

    WMSize *adSize = [WMSize sizeBy:WMProposalSize_Interstitial600_900];

    self.interstitial = [[WMInterstitialAd alloc] initWithSlotID:self.provider.data.key2 size:adSize];
    self.interstitial.delegate = self;

    [self.interstitial loadAdData];
}

- (BOOL)isReady {
    return self.interstitial.isAdValid;
}

- (void)present {
    [self.interstitial showAdFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark : - WMInterstitialAdDelegate

- (void)interstitialAdDidClick:(WMInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didClickInterstitialAd:interstitialAd];
}

- (void)interstitialAdDidClose:(WMInterstitialAd *)interstitialAd {
    [self.delegate adapter:self willDismissScreen:interstitialAd];
}

- (void)interstitialAdWillClose:(WMInterstitialAd *)interstitialAd {
    [self.delegate adapter:self willDismissScreen:interstitialAd];
}

- (void)interstitialAdDidLoad:(WMInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitialAd];
}

- (void)interstitialAd:(WMInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:interstitialAd didFailToReceive:[error localizedDescription]];
}

- (void)interstitialAdWillVisible:(WMInterstitialAd *_Nullable)interstitialAd {
    [self.delegate adapter:self willPresentScreen:interstitialAd];
}

@end
