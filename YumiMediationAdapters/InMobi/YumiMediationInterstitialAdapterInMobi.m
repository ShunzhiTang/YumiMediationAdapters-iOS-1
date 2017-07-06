//
//  YumiMediationInterstitialAdapterInMobi.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>

@interface YumiMediationInterstitialAdapterInMobi () <IMInterstitialDelegate>

@property (nonatomic) IMInterstitial *interstitial;

@end

@implementation YumiMediationInterstitialAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDInMobi
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    [IMSdk initWithAccountID:self.provider.data.key1];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    self.interstitial =
        [[IMInterstitial alloc] initWithPlacementId:[self.provider.data.key2 longLongValue] delegate:self];

    return self;
}

- (void)requestAd {
    [self.interstitial load];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial showFromViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self interstitialAd:interstitial didFailToReceive:[error localizedDescription]];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    [self.delegate adapter:self willPresentScreen:interstitial];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    [self.delegate adapter:self willDismissScreen:interstitial];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

@end
