//
//  YumiMediationInterstitialAdapterIronSource.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/10.
//

#import "YumiMediationInterstitialAdapterIronSource.h"
#import <IronSource/IronSource.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationInterstitialAdapterIronSource () <ISDemandOnlyInterstitialDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterIronSource

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDIronsource
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

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IronSource setConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IronSource setConsent:NO];
    }

    [IronSource setISDemandOnlyInterstitialDelegate:self];
    if (self.provider.data.key1.length == 0 || self.provider.data.key2.length == 0) {
        [self.delegate coreAdapter:self
                            coreAd:nil
                     didFailToLoad:@"No app id or instance id specified"
                            adType:self.adType];
        return nil;
    }
    [IronSource initISDemandOnly:self.provider.data.key1 adUnits:@[ IS_INTERSTITIAL ]];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"6.8.3";
}

- (void)requestAd {
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IronSource setConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IronSource setConsent:NO];
    }

    [IronSource loadISDemandOnlyInterstitial:self.provider.data.key2];
}

- (BOOL)isReady {
    return [IronSource hasISDemandOnlyInterstitial:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [IronSource showISDemandOnlyInterstitial:rootViewController instanceId:self.provider.data.key2];
}

#pragma mark - ISDemandOnlyInterstitialDelegate
/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad:(NSString *)instanceId {
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

/**
 Called after an interstitial has attempted to load but failed.
 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}
/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

/**
 Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}

/**
 Called after an interstitial has been displayed on the screen.
 */
- (void)interstitialDidShow:(NSString *)instanceId {
}

/**
 Called after an interstitial has attempted to show but failed.
 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
