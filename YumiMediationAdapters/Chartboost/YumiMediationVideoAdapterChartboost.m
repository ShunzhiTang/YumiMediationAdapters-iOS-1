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

@end

@implementation YumiMediationVideoAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDChartboost
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

    [Chartboost setShouldPrefetchVideoContent:YES];
    [Chartboost setAutoCacheAds:YES];
}

- (void)requestAd {
    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];

    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
}

- (BOOL)isReady {
    return [Chartboost hasRewardedVideo:CBLocationHomeScreen];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [Chartboost showRewardedVideo:CBLocationHomeScreen];
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

- (void)didCloseRewardedVideo:(CBLocation)location {
    [self.delegate adapter:self didCloseVideoAd:nil];

    // NOTE: in case didCompleteRewardedVideoWithReward not executed
    [self.delegate adapter:self videoAd:nil didReward:nil];
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    // NOTE: reward user in didClose delegate
}

@end
