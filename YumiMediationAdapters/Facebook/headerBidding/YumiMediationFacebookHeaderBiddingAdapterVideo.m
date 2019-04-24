//
//  YumiMediationFacebookHeaderBiddingAdapterVideo.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/9/5.
//

#import "YumiMediationFacebookHeaderBiddingAdapterVideo.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationFacebookHeaderBiddingAdapterVideo () <YumiMediationCoreAdapter, FBRewardedVideoAdDelegate>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;
@property (nonatomic) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic) NSString *bidPayloadFromServer;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationFacebookHeaderBiddingAdapterVideo

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                      forProviderID:kYumiMediationAdapterIDFacebookHeaderBidding
                                                      requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
    NSString *key =
        [NSString stringWithFormat:@"%@_%lu_%@", kYumiMediationAdapterIDFacebookHeaderBidding,
                                   (unsigned long)YumiMediationAdTypeVideo, YumiMediationHeaderBiddingToken];
    [[NSUserDefaults standardUserDefaults] setObject:FBAdSettings.bidderToken ?: @"" forKey:key];
}

#pragma mark - YumiMediationVideoAdapter
- (void)setUpBidPayloadValue:(NSString *)bidPayload {
    self.bidPayloadFromServer = bidPayload;
}

- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                         delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType{
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    return self;
}

- (void)requestAd {
    if (self.provider.data.payload.length == 0) {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:self.provider.data.errMessage adType:self.adType];
        return;
    }
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
    [self.delegate coreAdapter:self coreAd:rewardedVideoAd didFailToLoad:[error localizedDescription] adType:self.adType];
    self.rewardedVideoAd = nil;
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didReceivedCoreAd:rewardedVideoAd adType:self.adType];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    self.isReward = YES;
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:rewardedVideoAd didReward:YES adType:self.adType];
        
    }
    [self.delegate coreAdapter:self didCloseCoreAd:rewardedVideoAd isCompletePlaying:self.isReward adType:self.adType];
    self.rewardedVideoAd = nil;
    self.isReward = NO;
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didOpenCoreAd:rewardedVideoAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:rewardedVideoAd adType:self.adType];
}

/**
 Sent after an ad has been clicked by the person.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.delegate coreAdapter:self didClickCoreAd:rewardedVideoAd adType:self.adType];
}

@end
