//
//  YumiMediationVideoAdapterAppLovin.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAppLovin.h"
#import <AppLovinSDK/ALIncentivizedInterstitialAd.h>

@interface YumiMediationVideoAdapterAppLovin () <ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdLoadDelegate>

@property (nonatomic) ALIncentivizedInterstitialAd *video;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterAppLovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDAppLovin
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    ALSdk *sdk = [ALSdk sharedWithKey:provider.data.key1];
    self.video = [[ALIncentivizedInterstitialAd alloc] initWithSdk:sdk];
    self.video.adDisplayDelegate = self;
    self.video.adVideoPlaybackDelegate = self;
}

- (void)requestAd {
    [self.video preloadAndNotify:self];
}

- (BOOL)isReady {
    return self.video.isReadyForDisplay;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video show];
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
    self.isReward = YES;
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [self.delegate adapter:self didReceiveVideoAd:ad];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *error = [NSString stringWithFormat:@"fail to load applovin video with code %d", code];
    [self.delegate adapter:self videoAd:nil didFailToLoad:error];
}

@end
