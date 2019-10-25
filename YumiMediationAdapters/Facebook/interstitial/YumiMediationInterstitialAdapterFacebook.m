//
//  YumiMediationInterstitialAdapterFacebook.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterFacebook.h"
#import <FBAudienceNetwork/FBInterstitialAd.h>
#import <YumiMediationSDK/YumiLogger.h>

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
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (NSString *)networkVersion {
    return @"5.5.1";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---Facebook start request"];
    self.interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.provider.data.key1];
    self.interstitial.delegate = self;

    [self.interstitial loadAd];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Facebook chack ready status.%d",self.interstitial.isAdValid]];
    return self.interstitial.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Facebook present"];
    [self.interstitial showAdFromRootViewController:rootViewController];
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [[YumiLogger stdLogger] debug:@"---Facebook did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Facebook did fail to load.%@",error]];
    [self.delegate coreAdapter:self
                        coreAd:interstitialAd
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didClickCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [[YumiLogger stdLogger] debug:@"---Facebook did closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:interstitialAd isCompletePlaying:NO adType:self.adType];
    self.interstitial = nil;
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
