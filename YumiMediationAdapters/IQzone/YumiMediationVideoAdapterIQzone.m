//
//  YumiMediationVideoAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationVideoAdapterIQzone.h"
#import <IMDInterstitialViewController.h>
#import <IMDSDK.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationVideoAdapterIQzone () <IMDRewardedViewDelegate>

@property (nonatomic) IMDInterstitialViewController *rewardedVideo;
@property (nonatomic, assign) BOOL isVideoReady;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDIQzone
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter

- (nonnull id<YumiMediationVideoAdapter>)initWithProvider:(nonnull YumiMediationVideoProvider *)provider
                                                 delegate:(nonnull id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.rewardedVideo = [IMDSDK newRewardedInterstitialViewController:[[YumiTool sharedTool] topMostController]
                                                           placementID:self.provider.data.key1
                                                        loadedListener:self
                                                           andMetadata:nil];
    ;

    return self;
}

- (void)requestAd {
    self.isVideoReady = NO;
    [self.rewardedVideo load];
}

- (BOOL)isReady {

    return self.isVideoReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    [self.rewardedVideo show:rootViewController];
}

#pragma mark :IMDRewardedViewDelegate

- (void)adLoaded {
    self.isVideoReady = YES;

    [self.delegate adapter:self didReceiveVideoAd:self.rewardedVideo];
}

- (void)adFailedToLoad {
    self.isVideoReady = NO;
    [self.delegate adapter:self videoAd:self.rewardedVideo didFailToLoad:@"video load failed"];
}

- (void)adImpression {

    [self.delegate adapter:self didOpenVideoAd:self.rewardedVideo];
}

- (void)adDismissed {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:self.rewardedVideo didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:self.rewardedVideo];
}

- (void)adExpanded {
}

- (void)videoCompleted {
    self.isReward = YES;
}

- (void)videoSkipped {
    self.isReward = NO;
}

- (void)videoStarted {
    [self.delegate adapter:self didStartPlayingVideoAd:self.rewardedVideo];
}

- (void)videoTrackerFired {
}

- (void)adClicked {
    [self.delegate adapter:self didClickVideoAd:self.rewardedVideo];
}

@end
