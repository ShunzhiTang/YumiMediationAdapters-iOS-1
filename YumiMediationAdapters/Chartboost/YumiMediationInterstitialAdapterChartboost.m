//
//  YumiMediationInterstitialAdapterChartboost.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterChartboost.h"
#import <Chartboost/Chartboost.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationInterstitialAdapterChartboost () <ChartboostDelegate>
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDChartboost
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }

    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];
    [Chartboost setAutoCacheAds:NO];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }

    [Chartboost cacheInterstitial:CBLocationDefault];
}

- (BOOL)isReady {
    return [Chartboost hasInterstitial:CBLocationDefault];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [Chartboost showInterstitial:CBLocationDefault];
}

#pragma mark - ChartboostDelegate
- (void)didCacheInterstitial:(CBLocation)location {
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
    [self.delegate coreAdapter:self
                        coreAd:nil
                 didFailToLoad:[NSString stringWithFormat:@"Chartboost error code: %@", @(error)]
                        adType:self.adType];
}

/*!
 @abstract
 Called after an interstitial has been displayed on the screen.

 @param location The location for the Chartboost impression type.

 @discussion Implement to be notified of when an interstitial has
 been displayed on the screen for a given CBLocation.
 */
- (void)didDisplayInterstitial:(CBLocation)location {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)didDismissInterstitial:(CBLocation)location {
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}

- (void)didClickInterstitial:(CBLocation)location {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
