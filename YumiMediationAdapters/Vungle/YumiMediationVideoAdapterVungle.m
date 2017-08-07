//
//  YumiMediationVideoAdapterVungle.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterVungle.h"
#import <VungleSDK/VungleSDK.h>

@interface YumiMediationVideoAdapterVungle () <VungleSDKDelegate>

@end

@implementation YumiMediationVideoAdapterVungle

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDVungle
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
    
    NSError *error;
    NSString *appID = self.provider.data.key1;
    NSArray *placementIDsArray = @[self.provider.data.key2];
    VungleSDK *sdk = [VungleSDK sharedSDK];
    sdk.delegate = self;
    [sdk setLoggingEnabled:NO];
    [sdk startWithAppId:appID placements:placementIDsArray error:&error];
}

- (void)requestAd {
    NSError *error;
    VungleSDK *sdk = [VungleSDK sharedSDK];
    [sdk loadPlacementWithID:self.provider.data.key2 error:&error];
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK]isAdCachedForPlacementID:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController options:nil placementID:self.provider.data.key2 error:&error];

    if (error) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription]];
    }
}

#pragma mark - VungleSDKDelegate
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID{
    if (isAdPlayable) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    }else if (![self isReady]){
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"vungle no ad"];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID{
    [self.delegate adapter:self didOpenVideoAd:nil];
    
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID{
    if (info.completedView) {
        [self.delegate adapter:self didCloseVideoAd:nil];
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
}

- (void)vungleSDKDidInitialize{
    
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error{
    
}

@end
