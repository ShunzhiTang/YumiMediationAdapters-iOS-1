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

@interface YumiMediationVideoAdapterBytedanceAds ()<BURewardedVideoAdDelegate>

@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic , assign) BOOL isRewarded;

@end

@implementation YumiMediationVideoAdapterBytedanceAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDBytedanceAds
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [BUAdSDKManager setAppID:self.provider.data.key1];

    return self;
}

- (void)requestAd {
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.isShowDownloadBar = YES;
    
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.provider.data.key2 rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

- (BOOL)isReady {
    return self.rewardedVideoAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardedVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark: BURewardedVideoAdDelegate
//This method is called when video ad material loaded successfully.
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
    [self.delegate adapter:self didReceiveVideoAd:rewardedVideoAd];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
     [self.delegate adapter:self videoAd:rewardedVideoAd didFailToLoad:[error localizedDescription]];
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd{
   [self.delegate adapter:self didOpenVideoAd:rewardedVideoAd];
    [self.delegate adapter:self didStartPlayingVideoAd:rewardedVideoAd];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd{
   
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd{
    if (self.isRewarded) {
        [self.delegate adapter:self videoAd:rewardedVideoAd didReward:nil];
    }
    [self.delegate adapter:self didCloseVideoAd:rewardedVideoAd];
    
    self.isRewarded = NO;
    self.rewardedVideoAd = nil;
}
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
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
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    self.isRewarded = verify;
}

/**
 Server verification which is requested asynchronously is failed.
 Return value is not 2000.
 */
- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd{
    self.isRewarded = NO;
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd{
    self.isRewarded = NO;
}

@end
