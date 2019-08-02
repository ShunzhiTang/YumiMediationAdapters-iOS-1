//
//  YumiMediationInterstitialAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationInterstitialAdapterIQzone.h"
#import <IMDInterstitialViewController.h>
#import <IMDSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterIQzone () <IMDInterstitialViewDelegate>

@property (nonatomic) IMDInterstitialViewController *interstitial;
@property (nonatomic, assign) BOOL isInterstitialReady;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDIQzone
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

    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.interstitial = [IMDSDK newInterstitialViewController:[[YumiTool sharedTool] topMostController]
                                                          placementID:weakSelf.provider.data.key1
                                                       loadedListener:weakSelf
                                                          andMetadata:nil];
    });

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [self.interstitial setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_Consented];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [self.interstitial setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_NotConsented];
    }
    self.isInterstitialReady = NO;
    [self.interstitial load];
}

- (BOOL)isReady {

    return self.isInterstitialReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    BOOL isShow = [self.interstitial show:[[YumiTool sharedTool] topMostController]];
    if (!isShow) {
        [self.delegate coreAdapter:self
                    failedToShowAd:self.interstitial
                       errorString:@"IQzone failed to show"
                            adType:self.adType];
    }
}

#pragma mark : -IMDInterstitialViewDelegate

- (void)adLoaded {
    self.isInterstitialReady = YES;

    [self.delegate coreAdapter:self didReceivedCoreAd:self.interstitial adType:self.adType];
}

- (void)adClicked {
    [self.delegate coreAdapter:self didClickCoreAd:self.interstitial adType:self.adType];
}
- (void)adFailedToLoad {
    self.isInterstitialReady = NO;
    [self.delegate coreAdapter:self
                        coreAd:self.interstitial
                 didFailToLoad:@"interstitial load fail"
                        adType:self.adType];
}

- (void)adImpression {
    [self.delegate coreAdapter:self didOpenCoreAd:self.interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.interstitial adType:self.adType];
}

- (void)adDismissed {
    [self.delegate coreAdapter:self didCloseCoreAd:self.interstitial isCompletePlaying:NO adType:self.adType];
}

- (void)adExpanded {
}

- (void)videoCompleted {
}

- (void)videoSkipped {
}

- (void)videoStarted {
}

- (void)videoTrackerFired {
}

@end
