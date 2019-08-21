//
//  YumiMediationVideoAdapterInMobi.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterInMobi () <IMInterstitialDelegate>

@property (nonatomic) IMInterstitial *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;
@end

@implementation YumiMediationVideoAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInMobi
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

    self.video = [[IMInterstitial alloc] initWithPlacementId:[self.provider.data.key2 longLongValue] delegate:self];

    return self;
}

- (NSString*)networkVersion {
    return @"8.1.0";
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

    [self.video load];
    self.isReward = NO;
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showFromViewController:rootViewController];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self
                failedToShowAd:interstitial
                   errorString:error.localizedDescription
                        adType:self.adType];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {

    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:interstitial didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    self.isReward = YES;
}
///  Notifies the delegate that the user will leave application context.
- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

@end
