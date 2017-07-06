//
//  YumiMediationInterstitialAdapterUnity.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterUnity.h"
#import <UnityAds/UnityAds.h>

@interface YumiMediationInterstitialAdapterUnity () <UnityAdsDelegate>

@end

@implementation YumiMediationInterstitialAdapterUnity

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDUnity
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    [UnityAds initialize:self.provider.data.key1 delegate:self];
    [UnityAds setDebugMode:NO];

    return self;
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [UnityAds isReady:self.provider.data.key2];
}

- (void)present {
    [UnityAds show:[self.delegate rootViewControllerForPresentingModalView] placementId:self.provider.data.key2];
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    [self.delegate adapter:self willPresentScreen:nil];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    [self.delegate adapter:self willDismissScreen:nil];
}

@end
