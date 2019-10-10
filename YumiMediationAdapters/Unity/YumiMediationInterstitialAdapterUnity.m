//
//  YumiMediationInterstitialAdapterUnity.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterUnity.h"
#import "YumiMediationUnityInstance.h"
#import <UnityAds/UnityAds.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterUnity ()
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterUnity

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDUnity
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

    YumiMediationUnityInstance *unityInstance = [YumiMediationUnityInstance sharedInstance];
    NSString *key = [unityInstance getAdapterKeyWith:self.provider.data.key2 adType:self.adType];
    [unityInstance.adaptersDict setValue:self forKey:key];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"3.3.0";
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
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
    
    __weak typeof(self) weakSelf = self;
    if (![UnityAds isInitialized]) {
        [[YumiLogger stdLogger] debug:@"---Unity init SDK"];
        [UnityAds initialize:self.provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
        
        [[YumiMediationUnityInstance sharedInstance] unitySDKDidInitializeCompleted:^(BOOL isSuccessed) {
            [weakSelf callBackAdLodingResult];
            //initialize fail ,retry
            if (!isSuccessed) {
                 [UnityAds initialize:weakSelf.provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
            }
        }];
        return;
       }
    
    [self callBackAdLodingResult];
}

- (void)callBackAdLodingResult {
    if ([UnityAds isReady:self.provider.data.key2]) {
       [[YumiLogger stdLogger] debug:@"---Unity interstitial did load isReady is YES"];
       [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
        return ;
   }
   [[YumiLogger stdLogger] debug:@"---Unity interstitial not ready"];
        [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"Unity not ready." adType:self.adType];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---Unity cheack ready status.%d",[UnityAds isReady:self.provider.data.key2]]];
    return [UnityAds isReady:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Unity interstitial present"];
    [UnityAds show:rootViewController placementId:self.provider.data.key2];
}

@end
