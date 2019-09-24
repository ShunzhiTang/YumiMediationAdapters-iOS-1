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
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBaidu
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

- (void)dealloc {
    if (self.rewardVideo) {
        self.rewardVideo.delegate = nil;
        self.rewardVideo = nil;
    }
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    self.rewardVideo = [[BaiduMobAdRewardVideo alloc] init];

    self.rewardVideo.delegate = self;
    self.rewardVideo.publisherId = self.provider.data.key1;
    self.rewardVideo.AdUnitTag = self.provider.data.key2;

    return self;
}

- (NSString *)networkVersion {
    return @"4.6.7";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
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
    [self.delegate coreAdapter:self didReceivedCoreAd:video adType:self.adType];
}

/**
 *  视频加载缓存失败
 */
- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate coreAdapter:self
                        coreAd:video
                 didFailToLoad:[NSString stringWithFormat:@"error code %u", reason]
                        adType:self.adType];
}

#pragma mark - 视频播放delegate

/**
 *  视频开始播放
 */
- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    [self.delegate coreAdapter:self didOpenCoreAd:video adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:video adType:self.adType];
}

/**
 *  广告展示失败
 */
- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    self.isReward = NO;
    self.isPreloadVideo = NO;
    [self.delegate coreAdapter:self
                failedToShowAd:video
                   errorString:[NSString stringWithFormat:@"error code %u", reason]
                        adType:self.adType];
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
        [self.delegate coreAdapter:self coreAd:video didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:video isCompletePlaying:YES adType:self.adType];
    self.isReward = NO;
}

/**
 *  用户点击下载/查看详情
 @param progress 当前播放进度 单位百分比
 */
- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate coreAdapter:self didClickCoreAd:video adType:self.adType];
}
@end
