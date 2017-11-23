//
//  YumiMediationVideoAdapterUnity.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterUnity.h"
#import "YumiMediationUnityInstance.h"
#import <UnityAds/UnityAds.h>

@interface YumiMediationVideoAdapterUnity ()

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

    if (![UnityAds isInitialized]) {
        [UnityAds initialize:provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
    }
    [YumiMediationUnityInstance sharedInstance].unityVideoAdapter = self;
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

@end
