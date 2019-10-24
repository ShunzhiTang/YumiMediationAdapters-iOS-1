//
//  YumiMediationInterstitialAdapterBaidu.m
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import "YumiMediationInterstitialAdapterBaidu.h"
#import "YumiMediationInterstitialBaiduViewController.h"
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>
#import <BaiduMobAdSDK/BaiduMobAdRewardVideo.h>
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiLogger.h>

static NSString *const kYumiProviderExtraBaiduInterstitialAspectRatio = @"interstitialAspectRatio";
// 1: video
// 2: interstitial
// Default is 2
static NSString *const kYumiProviderExtraBaiduInventory = @"inventory";

@interface YumiMediationInterstitialAdapterBaidu () <BaiduMobAdInterstitialDelegate, BaiduMobAdRewardVideoDelegate>

@property (nonatomic) BaiduMobAdInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL interstitialIsReady;

@property (nonatomic) YumiMediationInterstitialBaiduViewController *presentAdVc;
@property (nonatomic, assign) CGSize adSize;
@property (nonatomic, assign) float aspectRatio;
// 1 video
// 2 interstitial (default)
@property (nonatomic) BaiduMobAdRewardVideo *rewardVideo;
@property (nonatomic, assign) BOOL isPreloadVideo;

@end

@implementation YumiMediationInterstitialAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBaidu
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

- (void)dealloc {
    [self clearInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (NSString *)networkVersion {
    return @"4.6.7";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // request video
    if ([self.provider.data.extra[kYumiProviderExtraBaiduInventory] isKindOfClass:[NSNumber class]] && [self.provider.data.extra[kYumiProviderExtraBaiduInventory] integerValue] == 1) {
        self.isPreloadVideo = NO;
        // video
        if (!self.rewardVideo) {
            self.rewardVideo = [[BaiduMobAdRewardVideo alloc] init];
            self.rewardVideo.delegate = self;
            self.rewardVideo.publisherId = self.provider.data.key1;
            self.rewardVideo.AdUnitTag = self.provider.data.key2;
        }

        [self.rewardVideo load];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YumiLogger stdLogger] debug:@"---Baidu start request"];
        weakSelf.interstitialIsReady = NO;
        weakSelf.interstitial = [[BaiduMobAdInterstitial alloc] init];
        weakSelf.interstitial.delegate = weakSelf;
        weakSelf.interstitial.AdUnitTag = weakSelf.provider.data.key2;

        // aspectRatio = width : height
        if (!
            [self.provider.data.extra[kYumiProviderExtraBaiduInterstitialAspectRatio] isKindOfClass:[NSNumber class]]) {
            self.aspectRatio = 0;
        } else {
            self.aspectRatio = [self.provider.data.extra[kYumiProviderExtraBaiduInterstitialAspectRatio] floatValue];
        }

        if (self.aspectRatio == 0) {
            weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
            [weakSelf.interstitial load];
            return;
        }

        weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;

        float width = MIN(kSCREEN_WIDTH, kSCREEN_HEIGHT);
        float height = width / self.aspectRatio;

        self.adSize = CGSizeMake(width, height);

        [weakSelf.interstitial loadUsingSize:CGRectMake(0, 0, width, height)];
    });
}

- (BOOL)isReady {
    if ([self.provider.data.extra[kYumiProviderExtraBaiduInventory] isKindOfClass:[NSNumber class]]  && [self.provider.data.extra[kYumiProviderExtraBaiduInventory] integerValue] == 1) {
        if (self.isPreloadVideo && [self.rewardVideo isReady]) {
            return YES;
        }
        return NO;
    }
    return self.interstitialIsReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // present video
    if ([self.provider.data.extra[kYumiProviderExtraBaiduInventory] isKindOfClass:[NSNumber class]]  && [self.provider.data.extra[kYumiProviderExtraBaiduInventory] integerValue] == 1) {
        [self.rewardVideo showFromViewController:rootViewController];
        return;
    }
    if (self.aspectRatio == 0) {
        [self.interstitial presentFromRootViewController:rootViewController];
        return;
    }
    YumiMediationInterstitialBaiduViewController *vc = [[YumiMediationInterstitialBaiduViewController alloc] init];
    self.presentAdVc = vc;
    __weak typeof(self) weakSelf = self;

    [rootViewController
        presentViewController:self.presentAdVc
                     animated:NO
                   completion:^{
                       [weakSelf.presentAdVc presentBaiduInterstitial:weakSelf.interstitial adSize:weakSelf.adSize];
                   }];
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [[YumiLogger stdLogger] debug:@"---Baidu interstitial did load"];
    self.interstitialIsReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [[YumiLogger stdLogger] debug:@"---Baidu interstitial did fail to load"];
    self.interstitialIsReady = NO;
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:@"Baidu ad load fail" adType:self.adType];

    [self clearInterstitial];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = NO;
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason)reason {
    [self.delegate coreAdapter:self
                failedToShowAd:interstitial
                   errorString:@"Baidu interstitial failed to show"
                        adType:self.adType];
    [self clearInterstitial];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    [[YumiLogger stdLogger] debug:@"---Baidu interstitial closed"];
    __weak typeof(self) weakSelf = self;
    [self.presentAdVc dismissViewControllerAnimated:NO
                                         completion:^{
                                             [weakSelf.delegate coreAdapter:weakSelf
                                                             didCloseCoreAd:interstitial
                                                          isCompletePlaying:NO
                                                                     adType:weakSelf.adType];

                                             [weakSelf clearInterstitial];
                                         }];
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
}

/**
 *  用户点击关闭
 @param progress 当前播放进度 单位百分比 （注意浮点数）
 */
- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    
    [self.delegate coreAdapter:self didCloseCoreAd:video isCompletePlaying:NO adType:self.adType];
}

/**
 *  用户点击下载/查看详情
 @param progress 当前播放进度 单位百分比
 */
- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate coreAdapter:self didClickCoreAd:video adType:self.adType];
}

- (void)clearInterstitial {
    if (self.presentAdVc) {
        self.presentAdVc = nil;
    }
    if (self.interstitial) {
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    if (self.rewardVideo) {
        self.rewardVideo.delegate = nil;
        self.rewardVideo = nil;
    }
}

@end
