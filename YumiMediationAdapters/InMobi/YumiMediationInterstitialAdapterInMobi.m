//
//  YumiMediationInterstitialAdapterInMobi.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterInMobi () <IMInterstitialDelegate>

@property (nonatomic) IMInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterInMobi
- (NSString *)networkVersion {
    return @"7.4.0";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInMobi
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    NSDictionary *consentDict = nil;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(YES) };
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(NO) };
    }

    // Initialize InMobi SDK with your account ID
    [IMSdk initWithAccountID:provider.data.key1 consentDictionary:consentDict];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    self.interstitial =
        [[IMInterstitial alloc] initWithPlacementId:[provider.data.key2 longLongValue] delegate:self];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(YES) }];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(NO) }];
    }
    [[YumiLogger stdLogger] debug:@"---Inmobi start request"];
    [self.interstitial load];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Inmobi cheack ready status.%d",[self.interstitial isReady]]];
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Inmobi present"];
    [self.interstitial showFromViewController:rootViewController];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    [[YumiLogger stdLogger] debug:@"---Inmobi did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [[YumiLogger stdLogger] debug:@"---Inmobi did fail to load"];
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    [[YumiLogger stdLogger] debug:@"---Inmobi closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:NO adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self
                failedToShowAd:interstitial
                   errorString:error.localizedDescription
                        adType:self.adType];
}
@end
