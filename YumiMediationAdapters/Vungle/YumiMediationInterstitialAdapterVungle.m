//
//  YumiMediationInterstitialAdapterVungle.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import "YumiMediationInterstitialAdapterVungle.h"
#import "YumiMediationVungleInstance.h"
#import <VungleSDK/VungleSDK.h>

@implementation YumiMediationInterstitialAdapterVungle

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDVungle
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    YumiMediationVungleInstance *vungleInstance = [YumiMediationVungleInstance sharedInstance];
    if (!vungleInstance.vungleInterstitialAdapters) {
        vungleInstance.vungleInterstitialAdapters = [NSMutableArray new];
    }
    [vungleInstance.vungleInterstitialAdapters addObject:self];

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
    if (sdk.isInitialized) {
        [sdk loadPlacementWithID:self.provider.data.key3 error:&error];
    } else {
        [[YumiMediationVungleInstance sharedInstance] interstitialVungleSDKFailedToInitializeWith:self];
    }
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.provider.data.key3];
}

- (void)present {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:[self.delegate rootViewControllerForPresentingModalView]
                          options:nil
                      placementID:self.provider.data.key3
                            error:&error];

    if (error) {
        [self.delegate adapter:self interstitialAd:nil didFailToReceive:[error localizedDescription]];
    }
}

@end
