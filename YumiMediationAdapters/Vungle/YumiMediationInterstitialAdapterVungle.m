//
//  YumiMediationInterstitialAdapterVungle.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import "YumiMediationInterstitialAdapterVungle.h"
#import "YumiMediationVungleInstance.h"
#import <VungleSDK/VungleSDK.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationInterstitialAdapterVungle ()

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterVungle

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDVungle
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

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
    return @"6.4.2";
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
        [sdk loadPlacementWithID:self.provider.data.key3 error:&error];
    } else {
        [[YumiMediationVungleInstance sharedInstance] interstitialVungleSDKFailedToInitializeWith:self];
    }
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.provider.data.key3];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController options:nil placementID:self.provider.data.key3 error:&error];

    if (error) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:[error localizedDescription] adType:self.adType];
    }
}

@end
