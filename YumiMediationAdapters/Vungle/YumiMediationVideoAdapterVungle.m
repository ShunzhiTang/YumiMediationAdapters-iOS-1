//
//  YumiMediationVideoAdapterVungle.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterVungle.h"
#import "YumiMediationVungleInstance.h"
#import <VungleSDK/VungleSDK.h>

@interface YumiMediationVideoAdapterVungle ()

@end

@implementation YumiMediationVideoAdapterVungle

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDVungle
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    YumiMediationVungleInstance *vungleInstance = [YumiMediationVungleInstance sharedInstance];
    vungleInstance.vungleVideoAdapter = self;

    NSError *error;
    NSString *appID = self.provider.data.key1;
    VungleSDK *sdk = [VungleSDK sharedSDK];
    sdk.delegate = vungleInstance;
    [sdk setLoggingEnabled:NO];
    [sdk startWithAppId:appID error:&error];

    return self;
}

- (void)requestAd {
    NSError *error;
    VungleSDK *sdk = [VungleSDK sharedSDK];
    [sdk loadPlacementWithID:self.provider.data.key2 error:&error];
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController options:nil placementID:self.provider.data.key2 error:&error];

    if (error) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription] isRetry:NO];
    }
}

@end
