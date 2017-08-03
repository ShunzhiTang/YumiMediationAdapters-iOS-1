//
//  YumiMediationVideoAdapterMobvista.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/3.
//
//

#import "YumiMediationVideoAdapterMobvista.h"
#import <MVSDK/MVSDK.h>
#import <MVSDKReward/MVRewardAdManager.h>

@interface YumiMediationVideoAdapterMobvista ()<MVRewardAdLoadDelegate , MVRewardAdShowDelegate>

@property (assign) BOOL isAdReady;
@property (nonatomic) MVRewardAdManager  *videoAd;

@end

@implementation YumiMediationVideoAdapterMobvista

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDMobvista
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark: YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider delegate:(id<YumiMediationVideoAdapterDelegate>)delegate{
    
    self.provider = provider;
    self.delegate = delegate;
    self.videoAd = [MVRewardAdManager sharedInstance];
}

- (void)requestAd{
    
   [self.videoAd loadVideo:self.provider.data.key1 delegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController{
    [self.videoAd showVideo:self.provider.data.key1 withRewardId:self.provider.data.key2 userId:self.provider.data.key3 ?: @"" delegate:self viewController:rootViewController];
}

- (BOOL)isReady{
    return self.isAdReady;
}

#pragma mark: - MVRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId
{
    self.isAdReady = YES;
    [self.delegate adapter:self didReceiveVideoAd:self.videoAd];
}
- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error
{
    self.isAdReady = NO;
    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription]];
}

#pragma mark: - MVRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId
{
    [self.delegate adapter:self didOpenVideoAd:self.videoAd];
}
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error
{
    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription]];
}
- (void)onVideoAdClicked:(nullable NSString *)unitId
{
    [self.delegate adapter:self didCloseVideoAd:self.videoAd];
}
- (void)onVideoAdDismissed:(NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(MVRewardAdInfo *)rewardInfo
{
    if (rewardInfo) {
        
        [self.delegate adapter:self videoAd:self.videoAd didReward:rewardInfo];
    }
}

@end
