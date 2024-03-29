//
//  YumiMediationInterstitialAdapterPlayableAds.m
//  Pods
//
//  Created by generator on 22/01/2018.
//
//

#import "YumiMediationInterstitialAdapterPlayableAds.h"
#import <YumiMediationSDK/PlayableAds.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>
#import <YumiMediationSDK/PlayableAdsGDPR.h>

@interface YumiMediationInterstitialAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDPlayableAds
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

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return  @"2.6.0";
}

- (void)requestAd {
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusPersonalized];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
         [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusNonPersonalized];
    }
    
    // TODO: request ad
    [[YumiLogger stdLogger] debug:@"---ZplayAds start request"];
    self.interstitial = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
    self.interstitial.autoLoad = NO;
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    // TODO: check if ready
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---ZplayAds did present"];
    [self.interstitial present];
}

#pragma mark : -- PlayableAdsDelegate
- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
}
- (void)playableAdsDidLoad:(PlayableAds *)ads {
     [[YumiLogger stdLogger] debug:@"---ZplayAds did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:ads adType:self.adType];
}
- (void)playableAds:(PlayableAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:ads didFailToLoad:error.localizedDescription adType:self.adType];
}
- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didCloseCoreAd:ads isCompletePlaying:NO adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---ZplayAds did close"];
}

- (void)playableAdsDidClick:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didClickCoreAd:ads adType:self.adType];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didOpenCoreAd:ads adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ads adType:self.adType];
}

@end
