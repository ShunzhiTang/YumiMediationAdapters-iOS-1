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

@interface YumiMediationInterstitialAdapterMintegral () <MTGInterstitialAdLoadDelegate, MTGInterstitialAdShowDelegate>
@property (nonatomic, strong) MTGInterstitialAdManager *interstitialAdManager;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) YumiMediationAdType adType;

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
        if (!weakSelf.interstitialAdManager) {
            weakSelf.interstitialAdManager =
                [[MTGInterstitialAdManager alloc] initWithUnitID:weakSelf.provider.data.key3 adCategory:0];
        }
    });
    return self;
}

- (void)requestAd {
    [_interstitialAdManager loadWithDelegate:self];
}

- (BOOL)isReady {
    return self.available;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    self.available = NO;
    [_interstitialAdManager showWithDelegate:self presentingViewController:rootViewController];
}

#pragma mark - Interstitial Delegate Methods
- (void)onInterstitialLoadSuccess:(MTGInterstitialAdManager *)adManager {
    self.available = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}
- (void)onInterstitialLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialAdManager *_Nonnull)adManager {
    self.available = NO;
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
    self.available = NO;
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}
- (void)onInterstitialAdClick:(MTGInterstitialAdManager *)adManager {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
