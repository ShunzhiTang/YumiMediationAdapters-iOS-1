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

@interface YumiMediationVideoAdapterMobvista () <MVRewardAdLoadDelegate, MVRewardAdShowDelegate>

@property (nonatomic) MVRewardAdManager *videoAd;

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

#pragma mark : YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {

    self.provider = provider;
    self.delegate = delegate;

    NSString *key1 = @"";
    NSString *key2 = @"";
    if (self.provider.data.key1) {
        NSArray *keys = [self.provider.data.key1 componentsSeparatedByString:@"_"];
        if (keys.count == 2) {
            key1 = keys.firstObject;
            key2 = keys.lastObject;
        }
    }

    [[MVSDK sharedInstance] setAppID:key1 ApiKey:key2];
}

- (void)requestAd {

    self.videoAd = [MVRewardAdManager sharedInstance];
    [self.videoAd loadVideo:self.provider.data.key2 delegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.videoAd showVideo:self.provider.data.key2
               withRewardId:self.provider.data.key3
                     userId:@""
                   delegate:self
             viewController:rootViewController];
}

- (BOOL)isReady {

    return [self.videoAd isVideoReadyToPlay:self.provider.data.key2];
}

#pragma mark : - MVRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId {

    [self.delegate adapter:self didReceiveVideoAd:self.videoAd];
}
- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error {

    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription]];
}

#pragma mark : - MVRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId {
    [self.delegate adapter:self didOpenVideoAd:self.videoAd];
}
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    [self.delegate adapter:self videoAd:self.videoAd didFailToLoad:[error localizedDescription]];
}

- (void)onVideoAdDismissed:(NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(MVRewardAdInfo *)rewardInfo {
    [self.delegate adapter:self didCloseVideoAd:self.videoAd];
    if (rewardInfo) {

        [self.delegate adapter:self videoAd:self.videoAd didReward:rewardInfo];
    }
}

@end
