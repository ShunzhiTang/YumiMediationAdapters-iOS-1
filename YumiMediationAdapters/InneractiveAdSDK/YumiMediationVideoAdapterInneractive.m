//
//  YumiMediationVideoAdapterInneractive.m
//  Pods
//
//  Created by generator on 17/05/2019.
//
//

#import "YumiMediationVideoAdapterInneractive.h"

@interface YumiMediationVideoAdapterInneractive ()

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterInneractive

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInneractive
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];
    
    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;
    
    return self;
}

- (void)requestAd {
   
}

- (BOOL)isReady {
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
   
}

@end
