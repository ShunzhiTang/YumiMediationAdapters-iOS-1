//
//  YumiMediationVideoAdapterAppLovin.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAppLovin.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterAppLovin () <ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdLoadDelegate,
                                                 ALAdRewardDelegate>

@property (nonatomic) ALIncentivizedInterstitialAd *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL isConfigured;

@end

@implementation YumiMediationVideoAdapterAppLovin
- (NSString *)networkVersion {
    return @"6.9.4";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAppLovin
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

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
        [self.video preloadAndNotify:self];
        return;
    }
    [[YumiLogger stdLogger] debug:@"---Applovin start init"];
    __weak __typeof(self)weakSelf = self;
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration * _Nonnull configuration) {
        [[YumiLogger stdLogger] debug:@"---Applovin is configured"];
        weakSelf.isConfigured = YES;
        [[YumiLogger stdLogger] debug:@"---Applovin start request"];
        weakSelf.video = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier:weakSelf.provider.data.key1];
        [weakSelf.video preloadAndNotify:weakSelf];
    }];
    
    
}

- (BOOL)isReady {
    return self.video.isReadyForDisplay;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    self.video.adDisplayDelegate = self;
    self.video.adVideoPlaybackDelegate = self;
    [self.video showAndNotify:self];
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:ad didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad
             atPlaybackPercent:(NSNumber *)percentPlayed
                  fullyWatched:(BOOL)wasFullyWatched {
    // video end
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    [[YumiLogger stdLogger] debug:@"---Applovin did loaded"];
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    [[YumiLogger stdLogger] debug:@"---Applovin did fail to load"];
    NSString *error = [NSString stringWithFormat:@"fail to load applovin video with code %d", code];
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error adType:self.adType];
}

#pragma mark : ALAdRewardDelegate
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    self.isReward = YES;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    self.isReward = NO;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    self.isReward = NO;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    self.isReward = NO;
}

@end
