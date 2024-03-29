//
//  YumiMediationVideoAdapterFacebook.m
//  Pods
//
//  Created by generator on 05/12/2017.
//
//

#import "YumiMediationVideoAdapterFacebook.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationVideoAdapterFacebook () <FBRewardedVideoAdDelegate>
@property (nonatomic) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterFacebook
- (NSString *)networkVersion {
    return @"5.5.1";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDFacebook
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
    [[YumiLogger stdLogger] debug:@"---Facebook start request"];
    // FBRewardedVideoAd loadAd can only be called once
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.provider.data.key1];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Facebook cheack ready status.%d",self.rewardedVideoAd.isAdValid]];
    return self.rewardedVideoAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Facebook present"];
    [self.rewardedVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark :- FBRewardedVideoAdDelegate
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Facebook did fail to load.%@",error]];
    [self.delegate coreAdapter:self
                        coreAd:rewardedVideoAd
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [[YumiLogger stdLogger] debug:@"---Facebook did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [[YumiLogger stdLogger] debug:@"---Facebook did rewarded"];
        [self.delegate coreAdapter:self coreAd:rewardedVideoAd didReward:YES adType:self.adType];
    }
    [[YumiLogger stdLogger] debug:@"---Facebook did closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:rewardedVideoAd isCompletePlaying:YES adType:self.adType];
    self.isReward = NO;
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didOpenCoreAd:rewardedVideoAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didClickCoreAd:rewardedVideoAd adType:self.adType];
}
@end
