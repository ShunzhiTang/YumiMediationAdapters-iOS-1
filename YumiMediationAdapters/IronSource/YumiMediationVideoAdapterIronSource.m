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
    [[YumiLogger stdLogger] debug:@"---IronSource init Demand video"];
    return self;
}

- (NSString *)networkVersion {
    return @"6.8.7";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
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
    self.isReward = NO;
    
    [IronSource loadISDemandOnlyRewardedVideo:self.provider.data.key2];
    [[YumiLogger stdLogger] debug:@"---IronSource video start request"];
}

- (BOOL)isReady {
    return [IronSource hasISDemandOnlyRewardedVideo:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---IronSource video did present"];
    [IronSource showISDemandOnlyRewardedVideo:rootViewController instanceId:self.provider.data.key2];
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate

- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    [[YumiLogger stdLogger] debug:@"---IronSource video did load"];
   [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [[YumiLogger stdLogger] debug:@"---IronSource video load fail"];
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    [[YumiLogger stdLogger] debug:@"---IronSource video did close"];
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    self.isReward = YES;
    [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---IronSource video did reward"];
}


@end
