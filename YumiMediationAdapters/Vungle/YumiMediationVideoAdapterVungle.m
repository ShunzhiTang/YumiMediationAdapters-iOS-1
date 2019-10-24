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
    
    [VungleSDK sharedSDK].delegate = vungleInstance;
    
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"6.4.3";
}
- (void)requestAd {

    NSError *initError = nil;
    VungleSDK *sdk = [VungleSDK sharedSDK];
    [sdk setLoggingEnabled:NO];
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [sdk updateConsentStatus:VungleConsentAccepted consentMessageVersion:@"1"];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [sdk updateConsentStatus:VungleConsentDenied consentMessageVersion:@"1"];
    }
    
    if (sdk.isInitialized) {
        [self loadVungleAd];
        return;
    }
    
    [[YumiLogger stdLogger] debug:@"---Vungle init SDK"];
    [sdk startWithAppId:self.provider.data.key1 error:&initError];
    
    __weak typeof(self) weakSelf = self;
    [[YumiMediationVungleInstance sharedInstance] vungleSDKDidInitializeCompleted:^(BOOL isSuccessed) {
        if (isSuccessed) {
            [[YumiLogger stdLogger] debug:@"---Vungle init completed "];
            [weakSelf loadVungleAd];
            return ;
        }
        [[YumiLogger stdLogger] debug:@"--- Vungle init fail "];
        [weakSelf.delegate coreAdapter:self
                                              coreAd:nil
                                       didFailToLoad:@"vungleSDKFailedToInitialize"
                                              adType:weakSelf.adType];
    }];
}

- (void)loadVungleAd {
    [[YumiLogger stdLogger] debug:@"---Vungle video start load"];
    NSError *loadError = nil;
    [[VungleSDK sharedSDK] loadPlacementWithID:self.provider.data.key3 error:&loadError];
}

- (BOOL)isReady {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Vungle video did present"];
    NSError *error;
    [[VungleSDK sharedSDK] playAd:rootViewController options:nil placementID:self.provider.data.key2 error:&error];

    if (error) {
        [self.delegate coreAdapter:self failedToShowAd:nil errorString:[error localizedDescription] adType:self.adType];
    }
}

@end
