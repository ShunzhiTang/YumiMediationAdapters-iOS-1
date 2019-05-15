//
//  YumiMediationVideoAdapterPlayableAds.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterPlayableAds.h"
#import <YumiMediationSDK/AtmosplayAds.h>

@interface YumiMediationVideoAdapterPlayableAds () <AtmosplayAdsDelegate>

@property (nonatomic) AtmosplayAds *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDPlayableAds
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    self.video = [[AtmosplayAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
    self.video.delegate = self;
    self.video.autoLoad = YES;
    [self.video loadAd];

    return self;
}

- (void)requestAd {
    // playableads auto load
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video present];
}

#pragma mark - AtmosplayAdsDelegate

- (void)atmosplayAdsDidRewardUser:(AtmosplayAds *)ads {
    self.isReward = YES;
}

- (void)atmosplayAdsDidLoad:(AtmosplayAds *)ads {
    [self.delegate coreAdapter:self didReceivedCoreAd:ads adType:self.adType];
}

- (void)atmosplayAds:(AtmosplayAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)atmosplayAdsDidStartPlaying:(AtmosplayAds *)ads {
    [self.delegate coreAdapter:self didOpenCoreAd:ads adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ads adType:self.adType];
}

- (void)atmosplayAdsDidDismissScreen:(AtmosplayAds *)ads {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:ads didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:ads isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}
/// Tells the delegate that the ad is clicked
- (void)atmosplayAdsDidClick:(AtmosplayAds *)ads {
    [self.delegate coreAdapter:self didClickCoreAd:ads adType:self.adType];
}
@end
