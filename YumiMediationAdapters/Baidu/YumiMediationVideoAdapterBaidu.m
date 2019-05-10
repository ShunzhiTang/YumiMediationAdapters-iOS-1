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
@property (nonatomic, assign) BOOL isPreloadVideo;

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
    [self.rewardVideo load];
}

- (BOOL)isReady {

    if (self.isPreloadVideo && [self.rewardVideo isReady]) {
        return YES;
    }
    return NO;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardVideo showFromViewController:rootViewController];
}

#pragma mark - 视频缓存delegate
/**
 *  视频加载缓存成功
 */
- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
    self.isPreloadVideo = YES;
    [self.delegate adapter:self didReceiveVideoAd:video];
}

/**
 *  视频加载缓存失败
 */
- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate adapter:self videoAd:video didFailToLoad:[NSString stringWithFormat:@"%u", reason] isRetry:YES];
}

#pragma mark - 视频播放delegate

/**
 *  视频开始播放
 */
- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    
}

/**
 *  广告展示失败
 */
- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate adapter:self videoAd:video didFailToLoad:[NSString stringWithFormat:@"%u", reason] isRetry:YES];
}

/**
 *  广告完成播放
 */
- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    self.isReward = YES;
}

/**
 *  用户点击关闭
 @param progress 当前播放进度 单位百分比 （注意浮点数）
 */
- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:video didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:video];
}

/**
 *  用户点击下载/查看详情
 @param progress 当前播放进度 单位百分比
 */
- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    
}

@end
