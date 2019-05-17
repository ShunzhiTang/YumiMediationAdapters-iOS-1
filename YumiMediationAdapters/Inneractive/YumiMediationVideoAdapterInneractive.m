//
//  YumiMediationVideoAdapterInneractive.m
//  Pods
//
//  Created by generator on 17/05/2019.
//
//

#import "YumiMediationVideoAdapterInneractive.h"

@interface YumiMediationVideoAdapterInneractive ()

@end

@implementation YumiMediationVideoAdapterInneractive

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDInneractive
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    // TODO: setup code
}

- (void)requestAd {
    // TODO: request ad
}

- (BOOL)isReady {
    // TODO: check if ready
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // TODO: present video ad
}

// TODO: implement third party sdk delegate and delegate to mediation sdk

@end
