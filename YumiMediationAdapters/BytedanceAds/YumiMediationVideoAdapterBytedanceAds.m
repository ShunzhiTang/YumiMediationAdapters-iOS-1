//
//  YumiMediationVideoAdapterBytedanceAds.m
//  Pods
//
//  Created by generator on 23/05/2019.
//
//

#import "YumiMediationVideoAdapterBytedanceAds.h"
#import <BUAdSDK/BUAdSDK.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationVideoAdapterBytedanceAds () <BURewardedVideoAdDelegate>
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isRewarded;

@end

@implementation YumiMediationVideoAdapterBytedanceAds
- (NSString *)networkVersion {
    return @"2.4.6.7";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBytedanceAds
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

    [BUAdSDKManager setAppID:self.provider.data.key1];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---Bytedance start request"];
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.provider.data.key2 rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Bytedance ready status: %d",self.rewardedVideoAd.isAdValid]];
    return self.rewardedVideoAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardedVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark : BURewardedVideoAdDelegate
// This method is called when video ad material loaded successfully.
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    [[YumiLogger stdLogger] debug:@"---Bytedance did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [[YumiLogger stdLogger] debug:@"---Bytedance did fail to load"];
    [self.delegate coreAdapter:self coreAd:rewardedVideoAd didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didOpenCoreAd:rewardedVideoAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didClickCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.isRewarded) {
        [[YumiLogger stdLogger] debug:@"---Bytedance did rewarded"];
        [self.delegate coreAdapter:self coreAd:rewardedVideoAd didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self
                didCloseCoreAd:rewardedVideoAd
             isCompletePlaying:self.isRewarded
                        adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---Bytedance did closed"];
    self.isRewarded = NO;
    self.rewardedVideoAd = nil;
}
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error) {
        self.isRewarded = NO;
        return;
    }
    self.isRewarded = YES;
}

/**
 Server verification which is requested asynchronously is succeeded.
 @param verify :return YES when return value is 2000.
 */
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    self.isRewarded = verify;
}

/**
 Server verification which is requested asynchronously is failed.
 Return value is not 2000.
 */
- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    self.isRewarded = NO;
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd {
    self.isRewarded = NO;
}

@end
