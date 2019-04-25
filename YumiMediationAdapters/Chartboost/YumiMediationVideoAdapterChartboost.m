//
//  YumiMediationVideoAdapterChartboost.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationVideoAdapterChartboost.h"
#import <Chartboost/Chartboost.h>

@interface YumiMediationVideoAdapterChartboost () <ChartboostDelegate>
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDChartboost
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

    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];
    [Chartboost setShouldPrefetchVideoContent:YES];
    [Chartboost setAutoCacheAds:YES];

    return self;
}

- (void)requestAd {
    [Chartboost cacheRewardedVideo:CBLocationDefault];
}

- (BOOL)isReady {
    return [Chartboost hasRewardedVideo:CBLocationDefault];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [Chartboost showRewardedVideo:CBLocationDefault];
}

#pragma mark - ChartboostDelegate
- (void)didDisplayRewardedVideo:(CBLocation)location {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)didCacheRewardedVideo:(CBLocation)location {
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    [self.delegate coreAdapter:self
                        coreAd:nil
                 didFailToLoad:[NSString stringWithFormat:@"error code %@", @(error)]
                        adType:self.adType];
}

- (void)didDismissRewardedVideo:(CBLocation)location {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    self.isReward = YES;
}

- (void)didClickRewardedVideo:(CBLocation)location {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
@end
