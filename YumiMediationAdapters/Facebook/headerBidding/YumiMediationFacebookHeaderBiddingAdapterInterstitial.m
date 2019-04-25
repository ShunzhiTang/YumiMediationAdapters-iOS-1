//
//  YumiMediationFacebookHeaderBiddingAdapterInterstitial.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/9/18.
//

#import "YumiMediationFacebookHeaderBiddingAdapterInterstitial.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBInterstitialAd.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationFacebookHeaderBiddingAdapterInterstitial () <YumiMediationCoreAdapter,
                                                                     FBInterstitialAdDelegate>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;
@property (nonatomic) FBInterstitialAd *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationFacebookHeaderBiddingAdapterInterstitial

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebookHeaderBidding
                                                             requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
    NSString *key =
        [NSString stringWithFormat:@"%@_%lu_%@", kYumiMediationAdapterIDFacebookHeaderBidding,
                                   (unsigned long)YumiMediationAdTypeInterstitial, YumiMediationHeaderBiddingToken];
    [[NSUserDefaults standardUserDefaults] setObject:FBAdSettings.bidderToken ?: @"" forKey:key];
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
    if (self.provider.data.payload.length == 0) {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:self.provider.data.errMessage adType:self.adType];
        return;
    }
    [self.interstitial loadAdWithBidPayload:self.provider.data.payload];
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
