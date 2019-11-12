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
- (NSString *)networkVersion {
    return @"4.10.13";
}

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

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---GDT video start request"];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rewardVideoAd = [[GDTRewardVideoAd alloc] initWithAppId:weakSelf.provider.data.key1
                                                             placementId:weakSelf.provider.data.key2];
        weakSelf.rewardVideoAd.delegate = weakSelf;
        [weakSelf.rewardVideoAd loadAd];
    });
}

- (BOOL)isReady {
    if (self.rewardVideoAd.expiredTimestamp && self.rewardVideoAd.expiredTimestamp <= [[NSDate date] timeIntervalSince1970]) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:@"GDT video ad is not valid" adType:self.adType];
        self.rewardVideoAd.delegate = nil;
        self.rewardVideoAd = nil;
        return NO;
    }
    if (!self.rewardVideoAd.isAdValid) {
        [[YumiLogger stdLogger] debug:@"---GDT video: NO"];
        return NO;
    }
    [[YumiLogger stdLogger] debug:@"---GDT video: YES"];
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---GDT video present"];
    [self.rewardVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark - GDTRewardVideoAdDelegate
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
}

- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [[YumiLogger stdLogger] debug:@"---GDT video did load"];
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
        [[YumiLogger stdLogger] debug:@"---GDT video did rewarded"];
        [self.delegate coreAdapter:self coreAd:rewardedVideoAd didReward:YES adType:self.adType];
    }
    [[YumiLogger stdLogger] debug:@"---GDT video did closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:rewardedVideoAd isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
    self.rewardVideoAd.delegate = nil;
    self.rewardVideoAd = nil;
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [[YumiLogger stdLogger] debug:@"---GDT video did fail to load"];
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
