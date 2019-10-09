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
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDGDT
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

    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rewardVideoAd = [[GDTRewardVideoAd alloc] initWithAppId:weakSelf.provider.data.key1
                                                             placementId:weakSelf.provider.data.key2];
        weakSelf.rewardVideoAd.delegate = weakSelf;
    });

    return self;
}

- (NSString *)networkVersion {
    return @"4.10.13";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
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
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"GDT video ad is not valid" adType:self.adType];
        return;
    }

    [self.rewardVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark - GDTRewardVideoAdDelegate
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didReceivedCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didOpenCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didStartPlayingAd:rewardedVideoAd adType:self.adType];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:rewardedVideoAd didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:rewardedVideoAd isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate coreAdapter:self
                        coreAd:rewardedVideoAd
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didClickCoreAd:rewardedVideoAd adType:self.adType];
}
@end
