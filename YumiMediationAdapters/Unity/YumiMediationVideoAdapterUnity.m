//
//  YumiMediationVideoAdapterUnity.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterUnity.h"
#import <UnityAds/UnityAds.h>

@interface YumiMediationVideoAdapterUnity () <UnityAdsDelegate>

@end

@implementation YumiMediationVideoAdapterUnity

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDUnity
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

    [UnityAds initialize:provider.data.key1 delegate:self testMode:NO];
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [UnityAds isReady:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [UnityAds show:rootViewController placementId:self.provider.data.key2];
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    [self.delegate adapter:self didReceiveVideoAd:nil];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    [self.delegate adapter:self videoAd:nil didFailToLoad:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    [self.delegate adapter:self didCloseVideoAd:nil];

    if (state == kUnityAdsFinishStateCompleted) {
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
}

@end
