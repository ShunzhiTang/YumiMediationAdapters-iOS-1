//
//  YumiMediationInterstitialAdapterApplovin.m
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import "YumiMediationInterstitialAdapterApplovin.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationInterstitialAdapterApplovin () <ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic) ALInterstitialAd *interstitial;
@property (nonatomic) ALAd *ad;
@property (nonatomic) ALSdk *sdk;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterApplovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAppLovin
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

    self.sdk = [ALSdk sharedWithKey:self.provider.data.key1];

    self.interstitial = [[ALInterstitialAd alloc] initWithSdk:self.sdk];
    self.interstitial.adDisplayDelegate = self;

    return self;
}

- (void)requestAd {
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [ALPrivacySettings setHasUserConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [ALPrivacySettings setHasUserConsent:NO];
    }

    if (self.provider.data.key2.length == 0) {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"No zone identifier specified" adType:self.adType];
        return;
    }
    self.isAdReady = NO;
    [[self.sdk adService] loadNextAdForZoneIdentifier:self.provider.data.key2 andNotify:self];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial showAd:self.ad];
}

#pragma mark - Ad Load Delegate
- (void)adService:(nonnull ALAdService *)adService didLoadAd:(nonnull ALAd *)ad {
    self.ad = ad;
    self.isAdReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void)adService:(nonnull ALAdService *)adService didFailToLoadAdWithError:(int)code {
    [self.delegate coreAdapter:self
                        coreAd:nil
                 didFailToLoad:[NSString stringWithFormat:@"applovin error code:%d", code]
                        adType:self.adType];
}

#pragma mark - Ad Display Delegate
- (void)ad:(nonnull ALAd *)ad wasDisplayedIn:(nonnull UIView *)view {
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

- (void)ad:(nonnull ALAd *)ad wasHiddenIn:(nonnull UIView *)view {
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:NO adType:self.adType];
}

- (void)ad:(nonnull ALAd *)ad wasClickedIn:(nonnull UIView *)view {
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

@end
