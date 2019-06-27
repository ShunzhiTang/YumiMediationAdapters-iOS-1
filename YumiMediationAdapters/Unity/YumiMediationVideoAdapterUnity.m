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
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterUnity ()

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterUnity

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDUnity
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
    
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
        [gdprConsentMetaData commit];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
        [gdprConsentMetaData commit];
    }
    
    if (![UnityAds isInitialized]) {
        [UnityAds initialize:provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
    }
    [YumiMediationUnityInstance sharedInstance].unityVideoAdapter = self;

    return self;
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
        [gdprConsentMetaData commit];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
        [gdprConsentMetaData commit];
    }
    
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
