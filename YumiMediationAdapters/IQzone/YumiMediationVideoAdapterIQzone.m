//
//  YumiMediationVideoAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationVideoAdapterIQzone.h"
#import <IMDInterstitialViewController.h>
#import <IMDSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationVideoAdapterIQzone () <IMDRewardedViewDelegate>

@property (nonatomic) IMDInterstitialViewController *rewardedVideo;
@property (nonatomic, assign) BOOL isVideoReady;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDIQzone
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rewardedVideo = [IMDSDK newRewardedInterstitialViewController:[[YumiTool sharedTool] topMostController]
                                                                   placementID:weakSelf.provider.data.key1
                                                                loadedListener:weakSelf
                                                                   andMetadata:nil];
        ;
    });

    return self;
}

- (void)requestAd {
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [self.rewardedVideo setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_Consented];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [self.rewardedVideo setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_NotConsented];
    }

    self.isVideoReady = NO;
    [self.rewardedVideo load];
}

- (BOOL)isReady {

    return self.isVideoReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    BOOL isShow = [self.rewardedVideo show:[[YumiTool sharedTool] topMostController]];
    if (!isShow) {
        [self.delegate coreAdapter:self
                    failedToShowAd:self.rewardedVideo
                       errorString:@"IQzone failed to show"
                            adType:self.adType];
    }
}

#pragma mark :IMDRewardedViewDelegate

- (void)adLoaded {
    self.isVideoReady = YES;

    [self.delegate coreAdapter:self didReceivedCoreAd:self.rewardedVideo adType:self.adType];
}

- (void)adFailedToLoad {
    self.isVideoReady = NO;
    [self.delegate coreAdapter:self coreAd:self.rewardedVideo didFailToLoad:@"video load failed" adType:self.adType];
}

- (void)adImpression {
    [self.delegate coreAdapter:self didOpenCoreAd:self.rewardedVideo adType:self.adType];
}

- (void)adDismissed {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:self.rewardedVideo didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self
                didCloseCoreAd:self.rewardedVideo
             isCompletePlaying:self.isReward
                        adType:self.adType];
    self.isReward = NO;
}

- (void)adExpanded {
}

- (void)videoCompleted {
    self.isReward = YES;
}

- (void)videoSkipped {
    self.isReward = NO;
}

- (void)videoStarted {
    [self.delegate coreAdapter:self didStartPlayingAd:self.rewardedVideo adType:self.adType];
}

- (void)videoTrackerFired {
}

- (void)adClicked {
    [self.delegate coreAdapter:self didClickCoreAd:self.rewardedVideo adType:self.adType];
}

@end
