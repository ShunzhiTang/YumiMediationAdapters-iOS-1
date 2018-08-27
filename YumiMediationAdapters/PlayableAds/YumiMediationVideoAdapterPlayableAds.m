//
//  YumiMediationVideoAdapterPlayableAds.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterPlayableAds.h"
#import <PlayableAds/PlayableAds.h>

@interface YumiMediationVideoAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *video;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDPlayableAds
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    self.video = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
    self.video.delegate = self;
    self.video.autoLoad = YES;
    [self.video loadAd];

    return self;
}

- (void)requestAd {
    // playableads auto load
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video present];
}

#pragma mark - PlayableAdsDelegate

- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
    self.isReward = YES;
}

- (void)playableAdsDidLoad:(PlayableAds *)ads {
    [self.delegate adapter:self didReceiveVideoAd:self.video];
}

- (void)playableAds:(PlayableAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:self.video didFailToLoad:[error localizedDescription]];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate adapter:self didOpenVideoAd:self.video];
    [self.delegate adapter:self didStartPlayingVideoAd:self.video];
}

- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:self.video didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:self.video];
}

@end
