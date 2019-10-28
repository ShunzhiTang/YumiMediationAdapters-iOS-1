//
//  YumiMediationVideoAdapterOneway.m
//  Pods
//
//  Created by d on 30/10/2017.
//
//

#import "YumiMediationVideoAdapterOneway.h"
#import <OneWaySDK.h>
#import <YumiMediationSDK/YumiLogger.h>

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
    
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"2.1.0";
}

- (void)requestAd {
    
    [OneWaySDK configure:self.provider.data.key1];
    [OWRewardedAd initWithDelegate:self];
    [[YumiLogger stdLogger] debug:@"---OneWaySDK configure and set OWRewardedAd delegate "];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---OneWaySDK isReady result = %u ",[OWRewardedAd isReady]];
    [[YumiLogger stdLogger] debug:msg];
    return [OWRewardedAd isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---OneWaySDK did present"];
    [OWRewardedAd show:rootViewController];
    
}

#pragma mark : oneWaySDKRewardedAdDelegate
- (void)oneWaySDKRewardedAdReady {
    [[YumiLogger stdLogger] debug:@"---OneWaySDK did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    
    BOOL isReward = NO;
    if ([state integerValue] == kOneWaySDKFinishStateCompleted) {
        isReward = YES;
        [self.delegate coreAdapter:self coreAd:nil didReward:isReward adType:self.adType];
        [[YumiLogger stdLogger] debug:@"---OneWaySDK did reward"];
    }
    
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:isReward adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---OneWaySDK did close"];
}

- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message {
    if (error == kOneWaySDKErrorShowError || error == kOneWaySDKErrorVideoPlayerError) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:message adType:self.adType];
        return;
    }
    [[YumiLogger stdLogger] debug:@"---OneWaySDK load fail"];
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:message adType:self.adType];
}

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

@end
