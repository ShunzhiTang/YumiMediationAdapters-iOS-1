//
//  YumiMediationVideoAdapterMobvista.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/3.
//
//

#import "YumiMediationVideoAdapterMobvista.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterMobvista () <MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate>

@property (nonatomic) MTGRewardAdManager *videoAd;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterMobvista

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDMobvista
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
        weakSelf.videoAd = [MTGRewardAdManager sharedInstance];
    });

    return self;
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

    [self.videoAd loadVideo:self.provider.data.key3 delegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.videoAd showVideo:self.provider.data.key3
               withRewardId:self.provider.data.key4
                     userId:@""
                   delegate:self
             viewController:rootViewController];
}

- (BOOL)isReady {
    return [self.videoAd isVideoReadyToPlay:self.provider.data.key3];
}

#pragma mark : - MTGRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId {
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}
- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error {
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

#pragma mark : - MTGRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)onVideoAdDismissed:(NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(MTGRewardAdInfo *)rewardInfo {
    if (rewardInfo) {
        [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
}
///  Called when the ad is clicked
- (void)onVideoAdClicked:(nullable NSString *)unitId {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
