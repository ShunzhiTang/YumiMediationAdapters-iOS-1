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

@end

@implementation YumiMediationVideoAdapterAppLovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDAppLovin
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
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
    [self.delegate adapter:self didOpenVideoAd:ad];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:ad didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:ad];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
    [self.delegate adapter:self didStartPlayingVideoAd:ad];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad
             atPlaybackPercent:(NSNumber *)percentPlayed
                  fullyWatched:(BOOL)wasFullyWatched {
    // video end
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [self.delegate adapter:self didReceiveVideoAd:ad];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *error = [NSString stringWithFormat:@"fail to load applovin video with code %d", code];
    [self.delegate adapter:self videoAd:nil didFailToLoad:error isRetry:NO];
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
