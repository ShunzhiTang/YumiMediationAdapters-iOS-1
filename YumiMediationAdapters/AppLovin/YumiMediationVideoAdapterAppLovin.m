//
//  YumiMediationVideoAdapterAppLovin.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAppLovin.h"

@interface YumiMediationVideoAdapterAppLovin ()

@end

@implementation YumiMediationVideoAdapterAppLovin

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:@"10005"
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