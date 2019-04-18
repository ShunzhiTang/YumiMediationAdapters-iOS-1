//
//  YumiMediationVideoAdapterMobvista.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/3.
//
//

#import "YumiMediationVideoAdapterMobvista.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>

@interface YumiMediationVideoAdapterMobvista () <MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate>

@property (nonatomic) MTGRewardAdManager *videoAd;

@end

@implementation YumiMediationVideoAdapterMobvista

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDMobvista
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark : YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MTGSDK sharedInstance] setAppID:weakSelf.provider.data.key1 ApiKey:weakSelf.provider.data.key2];
        weakSelf.videoAd = [MTGRewardAdManager sharedInstance];
    });

    return self;
}

- (void)requestAd {
    [self.videoAd loadVideo:self.provider.data.key3 delegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.videoAd showVideo:self.provider.data.key3
               withRewardId:self.provider.data.key4
                     userId:@""
                   delegate:self
             viewController:rootViewController];
}

- (BOOL)isReady {
    return [self.videoAd isVideoReadyToPlay:self.provider.data.key3];
}

#pragma mark : - MTGRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId {
    [self.delegate adapter:self didReceiveVideoAd:self.videoAd];
}
- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error {
    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription] isRetry:NO];
}

#pragma mark : - MTGRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId {
    [self.delegate adapter:self didOpenVideoAd:self.videoAd];
}
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription] isRetry:NO];
}

- (void)onVideoAdDismissed:(NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(MTGRewardAdInfo *)rewardInfo {
    if (rewardInfo) {
        [self.delegate adapter:self videoAd:self.videoAd didReward:rewardInfo];
    }
    [self.delegate adapter:self didCloseVideoAd:self.videoAd];
}
///  Called when the ad is clicked
- (void)onVideoAdClicked:(nullable NSString *)unitId {
    [self.delegate adapter:self didClickVideoAd:self.videoAd];
}

@end
