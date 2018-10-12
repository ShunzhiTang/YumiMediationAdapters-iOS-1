//
//  YumiMediationFacebookHeaderBiddingAdapterVideo.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/9/5.
//

#import "YumiMediationFacebookHeaderBiddingAdapterVideo.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <FBAudienceNetwork/FBAdSettings.h>

@interface YumiMediationFacebookHeaderBiddingAdapterVideo () <YumiMediationVideoAdapter,FBRewardedVideoAdDelegate>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;
@property (nonatomic) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic) NSString *bidPayloadFromServer;

@end

@implementation YumiMediationFacebookHeaderBiddingAdapterVideo

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDFacebookHeaderBidding
                                                      requestType:YumiMediationSDKAdRequest];
    NSString *key = [NSString stringWithFormat:@"%@_%lu_%@",kYumiMediationAdapterIDFacebookHeaderBidding,(unsigned long)YumiMediationAdTypeVideo,YumiMediationHeaderBiddingToken];
    [[NSUserDefaults standardUserDefaults] setObject:FBAdSettings.bidderToken?:@"" forKey:key];
}

#pragma mark - YumiMediationVideoAdapter
- (void)setUpBidPayloadValue:(NSString *)bidPayload{
    self.bidPayloadFromServer = bidPayload;
}

- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];
    
    self.delegate = delegate;
    self.provider = provider;
    
    return self;
}

- (void)requestAd {
    // FBRewardedVideoAd loadAd can only be called once
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.provider.data.key1];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdWithBidPayload:self.provider.data.payload];
}

- (BOOL)isReady {
    return self.rewardedVideoAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardedVideoAd showAdFromRootViewController:rootViewController];
}

#pragma mark :- FBRewardedVideoAdDelegate

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:rewardedVideoAd didFailToLoad:[error localizedDescription]];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didReceiveVideoAd:rewardedVideoAd];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:rewardedVideoAd didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:rewardedVideoAd];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate adapter:self didOpenVideoAd:rewardedVideoAd];
    [self.delegate adapter:self didStartPlayingVideoAd:rewardedVideoAd];
}

@end
