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
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterVungle ()

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterVungle

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDVungle
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

    YumiMediationVungleInstance *vungleInstance = [YumiMediationVungleInstance sharedInstance];
    [vungleInstance.vungleVideoAdapters addObject:self];

    NSError *error;
    NSString *appID = self.provider.data.key1;
    VungleSDK *sdk = [VungleSDK sharedSDK];
    sdk.delegate = vungleInstance;
    [sdk setLoggingEnabled:NO];
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [sdk updateConsentStatus:VungleConsentAccepted consentMessageVersion:@"1"];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [sdk updateConsentStatus:VungleConsentDenied consentMessageVersion:@"1"];
    }
    [sdk startWithAppId:appID error:&error];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"6.4.3";
}

- (void)requestAd {
    NSError *error;
    VungleSDK *sdk = [VungleSDK sharedSDK];

    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [sdk updateConsentStatus:VungleConsentAccepted consentMessageVersion:@"1"];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [sdk updateConsentStatus:VungleConsentDenied consentMessageVersion:@"1"];
    }

    if (sdk.isInitialized) {
        [sdk loadPlacementWithID:self.provider.data.key2 error:&error];
    } else {
        [[YumiMediationVungleInstance sharedInstance] videoVungleSDKFailedToInitializeWith:self];
    }
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController options:nil placementID:self.provider.data.key2 error:&error];

    if (error) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:[error localizedDescription] adType:self.adType];
    }
}

@end
