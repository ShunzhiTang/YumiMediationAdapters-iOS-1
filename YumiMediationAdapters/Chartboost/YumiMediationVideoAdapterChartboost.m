//
//  YumiMediationVideoAdapterChartboost.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationVideoAdapterChartboost.h"
#import <Chartboost/Chartboost.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationVideoAdapterChartboost () <ChartboostDelegate>
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterChartboost
- (NSString *)networkVersion {
    return @"8.0.3";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDChartboost
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

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }
    [[YumiLogger stdLogger] debug:@"---chartboost start init"];
    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];
    [Chartboost setShouldPrefetchVideoContent:YES];
    [Chartboost setAutoCacheAds:YES];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }
    [[YumiLogger stdLogger] debug:@"---chartboost start request"];
    [Chartboost cacheRewardedVideo:CBLocationDefault];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---chartboost check ready status.%d",[Chartboost hasRewardedVideo:CBLocationDefault]];
    [[YumiLogger stdLogger] debug:msg];
    return [Chartboost hasRewardedVideo:CBLocationDefault];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---chartboost present"];
    [Chartboost showRewardedVideo:CBLocationDefault];
}

#pragma mark - ChartboostDelegate

- (void)didDisplayRewardedVideo:(CBLocation)location {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)didCacheRewardedVideo:(CBLocation)location {
    [[YumiLogger stdLogger] debug:@"---chartboost did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    [[YumiLogger stdLogger] debug:@"---chartboost did fail to load"];
    [self.delegate coreAdapter:self
                        coreAd:nil
                 didFailToLoad:[NSString stringWithFormat:@"error code %@", @(error)]
                        adType:self.adType];
}

- (void)didDismissRewardedVideo:(CBLocation)location {
    if (self.isReward) {
        [[YumiLogger stdLogger] debug:@"---chartboost did rewarded"];
        [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
    }
    [[YumiLogger stdLogger] debug:@"---chartboost did closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    self.isReward = YES;
}

- (void)didClickRewardedVideo:(CBLocation)location {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
@end
