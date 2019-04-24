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
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDFacebook
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                                delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType{
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

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

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial showAdFromRootViewController:rootViewController];
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:interstitialAd didFailToLoad:[error localizedDescription] adType:self.adType];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didClickCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitialAd isCompletePlaying:NO adType:self.adType];
}

/**
 Sent immediately before the impression of an FBInterstitialAd object will be logged.
 
 @param interstitialAd An FBInterstitialAd object sending the message.
 */
- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitialAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitialAd adType:self.adType];
}
@end
