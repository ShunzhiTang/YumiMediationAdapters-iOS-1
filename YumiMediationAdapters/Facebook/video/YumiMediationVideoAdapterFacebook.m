//
//  YumiMediationVideoAdapterFacebook.m
//  Pods
//
//  Created by generator on 05/12/2017.
//
//

#import "YumiMediationVideoAdapterFacebook.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface YumiMediationVideoAdapterFacebook () <FBRewardedVideoAdDelegate>

@property (nonatomic) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDFacebook
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (void)requestAd {
    // FBRewardedVideoAd loadAd can only be called once
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.provider.data.key1];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

- (BOOL)isReady {
    return self.rewardedVideoAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardedVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark :- FBRewardedVideoAdDelegate

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:rewardedVideoAd didFailToLoad:[error localizedDescription]];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didReceiveVideoAd:rewardedVideoAd];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:rewardedVideoAd didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:rewardedVideoAd];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didOpenVideoAd:rewardedVideoAd];
    [self.delegate adapter:self didStartPlayingVideoAd:rewardedVideoAd];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didClickVideoAd:rewardedVideoAd];
}
@end
