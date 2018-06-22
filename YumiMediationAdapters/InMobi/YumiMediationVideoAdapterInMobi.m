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
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDInMobi
                                                      requestType:YumiMediationSDKAdRequest];
}
 
#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];
    
    self.delegate = delegate;
    self.provider = provider;

    [IMSdk initWithAccountID:self.provider.data.key1];
    self.video = [[IMInterstitial alloc] initWithPlacementId:[self.provider.data.key2 longLongValue] delegate:self];
    
    return self;
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

    [self.delegate adapter:self didStartPlayingVideoAd:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    [self.provider.logger debug:@"InMobi video fail to present" extras:@{@"error" : error}];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {

    if (self.isReward) {
        [self.delegate adapter:self videoAd:interstitial didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    self.isReward = YES;
}

@end
