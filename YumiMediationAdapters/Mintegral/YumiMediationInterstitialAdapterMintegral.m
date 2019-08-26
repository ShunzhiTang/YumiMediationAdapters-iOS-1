//
//  YumiMediationInterstitialAdapterMintegral.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2019/2/28.
//

#import "YumiMediationInterstitialAdapterMintegral.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitial/MTGInterstitialAdManager.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>

// 1: interstitial video
// 2: interstitial
// Default is 2
static NSString *const kYumiProviderExtraMintegralInventory = @"inventory";

@interface YumiMediationInterstitialAdapterMintegral () <MTGInterstitialAdLoadDelegate, MTGInterstitialAdShowDelegate,MTGInterstitialVideoDelegate>
@property (nonatomic, strong) MTGInterstitialAdManager *interstitialAdManager;
@property (nonatomic, assign) BOOL isInterstitialAvailable;
@property (nonatomic, assign) YumiMediationAdType adType;

// Interstitial video
@property (nonatomic) MTGInterstitialVideoAdManager  *interstitialVideo;

@end

@implementation YumiMediationInterstitialAdapterMintegral
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDMobvista
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

    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:NO];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MTGSDK sharedInstance] setAppID:weakSelf.provider.data.key1 ApiKey:weakSelf.provider.data.key2];
    });
    return self;
}

- (NSString *)networkVersion {
    return @"5.3.3";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:NO];
    }
    
    // interstitial video
    if ([self.provider.data.extra[kYumiProviderExtraMintegralInventory] integerValue] == 1) {
        self.interstitialVideo = [[MTGInterstitialVideoAdManager alloc] initWithUnitID:self.provider.data.key3 delegate:self];
        
        [self.interstitialVideo loadAd];
        return;
    }
    // interstitial
    self.isInterstitialAvailable = NO;
    self.interstitialAdManager =
    [[MTGInterstitialAdManager alloc] initWithUnitID:self.provider.data.key3 adCategory:0];
    
    [self.interstitialAdManager loadWithDelegate:self];
}

- (BOOL)isReady {
    // interstitial video
    if ([self.provider.data.extra[kYumiProviderExtraMintegralInventory] integerValue] == 1) {
         return [self.interstitialVideo isVideoReadyToPlay:self.provider.data.key3];
    }
    // interstitial
    return self.isInterstitialAvailable;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // interstitial video
    if ([self.provider.data.extra[kYumiProviderExtraMintegralInventory] integerValue] == 1) {
        [self.interstitialVideo showFromViewController:rootViewController];
        return;
    }
    // interstitial
    [self.interstitialAdManager showWithDelegate:self presentingViewController:rootViewController];
}

#pragma mark - Interstitial Delegate Methods
- (void)onInterstitialLoadSuccess:(MTGInterstitialAdManager *)adManager {
    self.isInterstitialAvailable = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}
- (void)onInterstitialLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialAdManager *_Nonnull)adManager {
    self.isInterstitialAvailable = NO;
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}
- (void)onInterstitialShowSuccess:(MTGInterstitialAdManager *)adManager {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)onInterstitialShowFail:(nonnull NSError *)error adManager:(MTGInterstitialAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}
- (void)onInterstitialClosed:(MTGInterstitialAdManager *)adManager {
    self.isInterstitialAvailable = NO;
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}
- (void)onInterstitialAdClick:(MTGInterstitialAdManager *)adManager {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

#pragma mark - MTGInterstitialVideoDelegate
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}
- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager;
{
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted
                                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}

@end
