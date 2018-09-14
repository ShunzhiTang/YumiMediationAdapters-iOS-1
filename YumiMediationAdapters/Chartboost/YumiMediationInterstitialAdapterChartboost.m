//
//  YumiMediationInterstitialAdapterChartboost.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterChartboost.h"
#import <Chartboost/Chartboost.h>

@interface YumiMediationInterstitialAdapterChartboost () <ChartboostDelegate>

@end

@implementation YumiMediationInterstitialAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDChartboost
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    
    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];
    [Chartboost setAutoCacheAds:NO];
    return self;
}

- (void)requestAd {
    [Chartboost cacheInterstitial:CBLocationDefault];
}

- (BOOL)isReady {
    return [Chartboost hasInterstitial:CBLocationDefault];
}

- (void)present {
    [Chartboost showInterstitial:CBLocationDefault];
}

#pragma mark - ChartboostDelegate
- (void)didCacheInterstitial:(CBLocation)location {
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
    [self.delegate adapter:self
            interstitialAd:nil
          didFailToReceive:[NSString stringWithFormat:@"Chartboost error code: %@", @(error)]];
}

/*!
 @abstract
 Called after an interstitial has been displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has
 been displayed on the screen for a given CBLocation.
 */
- (void)didDisplayInterstitial:(CBLocation)location{
    [self.delegate adapter:self willPresentScreen:nil];
}

- (void)didDismissInterstitial:(CBLocation)location {
    [self.delegate adapter:self willDismissScreen:nil];
}

- (void)didClickInterstitial:(CBLocation)location {
    [self.delegate adapter:self didClickInterstitialAd:nil];
}

@end
