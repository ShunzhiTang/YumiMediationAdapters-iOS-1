//
//  YumiMediationVideoAdapterAppLovin.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAppLovin.h"
#import <AppLovinSDK/ALIncentivizedInterstitialAd.h>

@interface YumiMediationVideoAdapterAppLovin () <ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdLoadDelegate,
                                                 ALAdRewardDelegate>

@property (nonatomic) ALIncentivizedInterstitialAd *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterAppLovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAppLovin
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;
    // initialize Sdk
    ALSdk *sdk = [ALSdk sharedWithKey:provider.data.key1];
    self.video = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier:provider.data.key2 sdk:sdk];
    self.video.adDisplayDelegate = self;
    self.video.adVideoPlaybackDelegate = self;

    return self;
}

- (void)requestAd {
    [self.video preloadAndNotify:self];
}

- (BOOL)isReady {
    return self.video.isReadyForDisplay;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showAndNotify:self];
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:ad didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad
             atPlaybackPercent:(NSNumber *)percentPlayed
                  fullyWatched:(BOOL)wasFullyWatched {
    // video end
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *error = [NSString stringWithFormat:@"fail to load applovin video with code %d", code];
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error adType:self.adType];
}

#pragma mark : ALAdRewardDelegate
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    self.isReward = YES;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    self.isReward = NO;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    self.isReward = NO;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    self.isReward = NO;
}

- (void)userDeclinedToViewAd:(ALAd *)ad {
    self.isReward = NO;
}

@end
