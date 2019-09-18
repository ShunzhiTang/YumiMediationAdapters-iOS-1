//
//  YumiMediationInterstitialAdapterPlayableAds.m
//  Pods
//
//  Created by generator on 22/01/2018.
//
//

#import "YumiMediationInterstitialAdapterPlayableAds.h"
#import <YumiAdSDK/PlayableAds.h>
#import <YumiAdSDK/YumiMediationGDPRManager.h>

@interface YumiMediationInterstitialAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDPlayableAds
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"2.4.3";
}

- (void)requestAd {
    // TODO: request ad
    self.interstitial = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
    self.interstitial.autoLoad = NO;
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    // TODO: check if ready
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial present];
}

#pragma mark : -- PlayableAdsDelegate
- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
}
- (void)playableAdsDidLoad:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didReceivedCoreAd:ads adType:self.adType];
}
- (void)playableAds:(PlayableAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:ads didFailToLoad:error.localizedDescription adType:self.adType];
}
- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didCloseCoreAd:ads isCompletePlaying:NO adType:self.adType];
}

- (void)playableAdsDidClick:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didClickCoreAd:ads adType:self.adType];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didOpenCoreAd:ads adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ads adType:self.adType];
}

@end
