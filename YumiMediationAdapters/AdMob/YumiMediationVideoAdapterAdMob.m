//
//  YumiMediationVideoAdapterAdMob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationVideoAdapterAdMob () <GADRewardBasedVideoAdDelegate>

@end

@implementation YumiMediationVideoAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDAdMob
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

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    [GADRewardBasedVideoAd sharedInstance].delegate = self;
}

- (void)requestAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:self.provider.data.key1];
    });
}

- (BOOL)isReady {
    return [GADRewardBasedVideoAd sharedInstance].isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];
}

#pragma mark - GADRewardBasedVideoAdDelegate
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    [self.delegate adapter:self videoAd:rewardBasedVideoAd didReward:nil];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:rewardBasedVideoAd didFailToLoad:[error localizedDescription]];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didReceiveVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didOpenVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didStartPlayingVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didCloseVideoAd:rewardBasedVideoAd];
}

@end
