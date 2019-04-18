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

@end

@implementation YumiMediationVideoAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDChartboost
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

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
    [self.delegate adapter:self didOpenVideoAd:nil];

    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)didCacheRewardedVideo:(CBLocation)location {
    [self.delegate adapter:self didReceiveVideoAd:nil];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    [self.delegate adapter:self videoAd:nil didFailToLoad:[NSString stringWithFormat:@"error code %@", @(error)]];
}

- (void)didDismissRewardedVideo:(CBLocation)location {
    if (self.isReward) {
        self.isReward = NO;
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
    [self.delegate adapter:self didCloseVideoAd:nil];
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    self.isReward = YES;
}

- (void)didClickRewardedVideo:(CBLocation)location {
    [self.delegate adapter:self didClickVideoAd:nil];
}
@end
