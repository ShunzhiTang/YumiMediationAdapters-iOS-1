//
//  YumiMediationVideoAdapterGDT.m
//  Pods
//
//  Created by 王泽永 on 2018/11/14.
//

#import "YumiMediationVideoAdapterGDT.h"
#import <YumiGDT/GDTRewardVideoAd.h>

@interface YumiMediationVideoAdapterGDT () <GDTRewardedVideoAdDelegate>
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDGDT
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    self.rewardVideoAd =
        [[GDTRewardVideoAd alloc] initWithAppId:self.provider.data.key1 placementId:self.provider.data.key2];
    self.rewardVideoAd.delegate = self;

    return self;
}

- (void)requestAd {
    [self.rewardVideoAd loadAd];
}

- (BOOL)isReady {
    if (self.rewardVideoAd.expiredTimestamp <= [[NSDate date] timeIntervalSince1970]) {
        return NO;
    }
    if (!self.rewardVideoAd.isAdValid) {
        return NO;
    }
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.rewardVideoAd.expiredTimestamp <= [[NSDate date] timeIntervalSince1970] || !self.rewardVideoAd.isAdValid) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"GDT video Ad is not valid" isRetry:YES];
        return;
    }

    [self.rewardVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark - GDTRewardVideoAdDelegate
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didReceiveVideoAd:rewardedVideoAd];
}

- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didStartPlayingVideoAd:rewardedVideoAd];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:rewardedVideoAd didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:rewardedVideoAd];
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:rewardedVideoAd didFailToLoad:[error localizedDescription] isRetry:YES];
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didClickVideoAd:rewardedVideoAd];
}
@end
