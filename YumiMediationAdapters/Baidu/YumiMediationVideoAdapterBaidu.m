//
//  YumiMediationVideoAdapterBaidu.m
//  Pods
//
//  Created by generator on 26/09/2018.
//
//

#import "YumiMediationVideoAdapterBaidu.h"
#import <BaiduMobAdSDK/BaiduMobAdRewardVideo.h>
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>

@interface YumiMediationVideoAdapterBaidu () <BaiduMobAdRewardVideoDelegate>

@property (nonatomic) BaiduMobAdRewardVideo *rewardVideo;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign)BOOL isPreloadVideo;

@end

@implementation YumiMediationVideoAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDBaidu
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    self.rewardVideo = [[BaiduMobAdRewardVideo alloc] init];

    self.rewardVideo.delegate = self;
    self.rewardVideo.publisherId = self.provider.data.key1;
    self.rewardVideo.AdUnitTag = self.provider.data.key2;

    return self;
}

- (void)requestAd {
    self.isPreloadVideo = NO;
    [self.rewardVideo preload];
}

- (BOOL)isReady {
    
    if (self.isPreloadVideo && [self.rewardVideo isReady]) {
        return YES;
    }
    return NO;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardVideo loadAndDisplayWithViewController:rootViewController];
}

#pragma mark :BaiduMobAdRewardVideoDelegate
- (void)videoPreloadSuccess:(BaiduMobAdRewardVideo *)video {
    self.isPreloadVideo = YES;
    [self.delegate adapter:self didReceiveVideoAd:video];
}

- (void)videoPreloadFail:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate adapter:self videoAd:video didFailToLoad:[NSString stringWithFormat:@"%u", reason] isRetry:YES];
}

- (void)videoFailPresentScreen:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate adapter:self videoAd:video didFailToLoad:[NSString stringWithFormat:@"%u", reason] isRetry:YES];
}

- (void)videoDidFinishPlayingMedia:(BaiduMobAdRewardVideo *)video {
    self.isReward = YES;
}

- (void)userDidSkipPlayingMedia:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:video didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:video];
}

@end
