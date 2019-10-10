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
@property (nonatomic, assign) BOOL theFirstTime;

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
        self.theFirstTime = YES;
        [UnityAds initialize:provider.data.key1 delegate:[YumiMediationUnityInstance sharedInstance] testMode:NO];
    }

    YumiMediationUnityInstance *unityInstance = [YumiMediationUnityInstance sharedInstance];
    NSString *key = [unityInstance getAdapterKeyWith:self.provider.data.key2 adType:self.adType];
    [unityInstance.adaptersDict setValue:self forKey:key];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"3.1.0";
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

    [self checkUnityReadyStatus];
}

- (BOOL)checkUnityReadyStatus {
    if (!self.theFirstTime) {
        if ([UnityAds isReady]) {
            [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
        } else {
            [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"Unity not ready." adType:self.adType];
        }
        return [UnityAds isReady];
    }

    __weak __typeof(self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UnityAds isReady]) {
                dispatch_suspend(timer);
                [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:nil adType:weakSelf.adType];
            }
        });
    });
    dispatch_resume(timer);
    
    double delayInSeconds = self.provider.data.requestTimeout?:30;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_source_cancel(timer);
        if (![UnityAds isReady]) {
            [weakSelf.delegate coreAdapter:weakSelf coreAd:nil didFailToLoad:@"Unity not ready." adType:weakSelf.adType];
        }
    });
    self.theFirstTime = NO;
    return [UnityAds isReady];
}

- (BOOL)isReady {
    return [UnityAds isReady:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [UnityAds show:rootViewController placementId:self.provider.data.key2];
}

@end
