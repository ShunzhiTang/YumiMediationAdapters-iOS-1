//
//  YumiMediationVideoAdapterAdColony.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdColony.h"
#import <AdColony/AdColony.h>

@interface YumiMediationVideoAdapterAdColony () <AdColonyDelegate, AdColonyAdDelegate>

@end

@implementation YumiMediationVideoAdapterAdColony

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:@"10001"
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    [AdColony configureWithAppID:self.provider.data.key1 zoneIDs:@[ self.provider.data.key2 ] delegate:self logging:NO];
}

- (void)requestAd {
    // NOTE: AdColony do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [AdColony isVirtualCurrencyRewardAvailableForZone:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [AdColony playVideoAdForZone:self.provider.data.key2 withDelegate:self withV4VCPrePopup:NO andV4VCPostPopup:NO];
}

#pragma mark - AdColonyDelegate
- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID {
    if (available && [self isZoneIDMatched:zoneID]) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    }
}

#pragma mark - AdColonyAdDelegate
- (void)onAdColonyAdStartedInZone:(NSString *)zoneID {
    if ([self isZoneIDMatched:zoneID]) {
        [self.delegate adapter:self didStartPlayingVideoAd:nil];
    }
}

- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID {
    [self.delegate adapter:self didCloseVideoAd:nil];

    if (shown && [self isZoneIDMatched:zoneID]) {
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
}

#pragma mark - Helper method
- (BOOL)isZoneIDMatched:(NSString *)zoneID {
    return [zoneID isEqualToString:self.provider.data.key2];
}

@end
