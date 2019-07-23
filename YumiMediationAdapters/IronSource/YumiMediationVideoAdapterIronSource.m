//
//  YumiMediationVideoAdapterIronSource.m
//  Pods
//
//  Created by generator on 26/06/2017.
//
//

#import "YumiMediationVideoAdapterIronSource.h"
#import <IronSource/IronSource.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterIronSource () <ISDemandOnlyRewardedVideoDelegate>

@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterIronSource

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDIronsource
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

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IronSource setConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IronSource setConsent:NO];
    }

    [IronSource setISDemandOnlyRewardedVideoDelegate:self];
    [IronSource shouldTrackReachability:YES];
    if (self.provider.data.key1.length == 0 || self.provider.data.key2.length == 0) {
        [self.delegate coreAdapter:self
                            coreAd:nil
                     didFailToLoad:@"No app id or instance id specified"
                            adType:self.adType];
        return nil;
    }
    [IronSource initISDemandOnly:self.provider.data.key1 adUnits:@[ IS_REWARDED_VIDEO ]];
    return self;
}

- (void)requestAd {
    // NOTE: ironsource do not provide any method for requesting ad, it handles the request internally
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IronSource setConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IronSource setConsent:NO];
    }
}

- (BOOL)isReady {
    return [IronSource hasISDemandOnlyRewardedVideo:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [IronSource showISDemandOnlyRewardedVideo:rootViewController instanceId:self.provider.data.key2];
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate
// Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available and ready to be shown, NO otherwise.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available instanceId:(NSString *)instanceId {
    if (available) {
        [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
    } else {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"ironSource is not available" adType:self.adType];
    }
}

// Called after a rewarded video has been viewed completely and the user is eligible for reward.
//@param placementInfo An object that contains the placement's reward name and amount.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
    self.isReward = YES;
}

// Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

// Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

// Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose:(NSString *)instanceId {
    if (self.isReward) { // ironsource 确保无中途关闭并且奖励回调始终在关闭之前
        [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
        self.isReward = NO;
    }
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:self.isReward adType:self.adType];
}

// Invoked when the end user clicked on the RewardedVideo ad
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
