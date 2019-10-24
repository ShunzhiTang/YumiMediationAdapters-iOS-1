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
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterApplovin () <ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic) ALAd *ad;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL isConfigured;

@end

@implementation YumiMediationInterstitialAdapterApplovin
- (NSString *)networkVersion {
    return @"6.9.4";
}

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
    self.isConfigured = NO;
    self.isAdReady = NO;
    
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
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
    // applovin zone id can't be nil;
    if (self.provider.data.key1.length == 0) {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"No zone identifier specified" adType:self.adType];
        return;
    }
    
    if (self.isConfigured) {
        [[YumiLogger stdLogger] debug:@"---Applovin start request"];
        [[ALSdk shared].adService loadNextAdForZoneIdentifier:self.provider.data.key1 andNotify: self];
        return;
    }
    [[YumiLogger stdLogger] debug:@"---Applovin start init"];
    __weak __typeof(self)weakSelf = self;
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration * _Nonnull configuration) {
        [[YumiLogger stdLogger] debug:@"---Applovin is configured"];
        weakSelf.isConfigured = YES;
        [[YumiLogger stdLogger] debug:@"---Applovin start request"];
        [[ALSdk shared].adService loadNextAdForZoneIdentifier:weakSelf.provider.data.key1 andNotify: weakSelf];
    }];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // Optional: Assign delegates
    [ALInterstitialAd shared].adDisplayDelegate = self;
    [[ALInterstitialAd shared] showAd: self.ad];
}

#pragma mark - Ad Load Delegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [[YumiLogger stdLogger] debug:@"---Applovin did loaded"];
    self.ad = ad;
    self.isAdReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Applovin Interstitial failed to load with error code = %d", code]];
    [self.delegate coreAdapter:self
                           coreAd:nil
                    didFailToLoad:[NSString stringWithFormat:@"applovin error code:%d", code]
                           adType:self.adType];
    
}

#pragma mark - Ad Display Delegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:NO adType:self.adType];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

@end
