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

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterUnity

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self forProviderID:kYumiMediationAdapterIDUnity requestType:YumiMediationSDKAdRequest adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType{
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    if (![UnityAds isInitialized]) {
        [UnityAds initialize:provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
    }
    [YumiMediationUnityInstance sharedInstance].unityVideoAdapter = self;

    return self;
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
    if ([UnityAds isReady:self.provider.data.key2]) {
        [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
    }
}

- (BOOL)isReady {
    return [UnityAds isReady:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [UnityAds show:rootViewController placementId:self.provider.data.key2];
}

@end
