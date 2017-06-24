//
//  YumiMediationVideoAdapterInMobi.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>

@interface YumiMediationVideoAdapterInMobi () <IMInterstitialDelegate>

@property (nonatomic) IMInterstitial *video;

@end

@implementation YumiMediationVideoAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:@"10010"
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

    [IMSdk initWithAccountID:self.provider.data.key1];
    self.video = [[IMInterstitial alloc] initWithPlacementId:[self.provider.data.key2 longLongValue] delegate:self];
}

- (void)requestAd {
    [self.video load];
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showFromViewController:rootViewController];
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    [self.delegate adapter:self didReceiveVideoAd:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self videoAd:interstitial didFailToLoad:[error localizedDescription]];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    [self.delegate adapter:self didOpenVideoAd:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self didCloseVideoAd:interstitial];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    [self.delegate adapter:self didCloseVideoAd:interstitial];

    // NOTE: in case didRewardUserWithReward not executed
    [self.delegate adapter:self videoAd:interstitial didReward:nil];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    // NOTE: reward user in didDismiss delegate
}

@end
