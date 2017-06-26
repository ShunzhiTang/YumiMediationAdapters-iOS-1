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
                                                      forProvider:@"10021"
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

    VungleSDK *sdk = [VungleSDK sharedSDK];
    sdk.delegate = self;
    [sdk setLoggingEnabled:NO];
    [sdk startWithAppId:self.provider.data.key1];
}

- (void)requestAd {
    // NOTE: Vungle do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [VungleSDK sharedSDK].isAdPlayable;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController error:&error];

    if (error) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription]];
    }
}

#pragma mark - VungleSDKDelegate
- (void)vungleSDKwillShowAd {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo
                 willPresentProductSheet:(BOOL)willPresentProductSheet {
    if (!willPresentProductSheet) {
        [self.delegate adapter:self didCloseVideoAd:nil];
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    [self.delegate adapter:self didCloseVideoAd:nil];
    [self.delegate adapter:self videoAd:nil didReward:nil];
}

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable {
    if (isAdPlayable) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    }
}

@end
