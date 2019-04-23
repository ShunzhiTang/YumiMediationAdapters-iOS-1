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
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self forProviderID:kYumiMediationAdapterIDInMobi requestType:YumiMediationSDKAdRequest adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
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

- (void)presentFromRootViewController:(UIViewController *)rootViewController{
    [self.interstitial showFromViewController:rootViewController];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:YES adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error{
    [self.delegate coreAdapter:self failedToShowAd:interstitial errorString:error.localizedDescription adType:self.adType];
}
@end
