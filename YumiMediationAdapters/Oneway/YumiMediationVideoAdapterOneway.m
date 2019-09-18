//
//  YumiMediationVideoAdapterOneway.m
//  Pods
//
//  Created by d on 30/10/2017.
//
//

#import "YumiMediationVideoAdapterOneway.h"
#import <OneWaySDK.h>

@interface YumiMediationVideoAdapterOneway () <oneWaySDKRewardedAdDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterOneway

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDOneWay
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

    [OneWaySDK configure:self.provider.data.key1];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"2.1.0";
}

- (void)requestAd {
    if ([OneWaySDK isConfigured]) {
        [OWRewardedAd initWithDelegate:self];
    } else {
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"OneWaySDK no configured" adType:self.adType];
    }
}

- (BOOL)isReady {
    return [OWRewardedAd isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [OWRewardedAd show:rootViewController];
}

#pragma mark : oneWaySDKRewardedAdDelegate
- (void)oneWaySDKRewardedAdReady {
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    if ([state integerValue] == kOneWaySDKFinishStateCompleted) {
        [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
        [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
        return;
    }

    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}

- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message {
    if (error == kOneWaySDKErrorShowError || error == kOneWaySDKErrorVideoPlayerError) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:message adType:self.adType];
        return;
    }
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:message adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
