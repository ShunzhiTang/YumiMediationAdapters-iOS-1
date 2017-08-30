//
//  YumiMediationVideoAdapterPlayableAds.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterPlayableAds.h"
#import <PlayableAds/PlayableAds.h>

@interface YumiMediationVideoAdapterPlayableAds ()<PlayableAdsDelegate>

@end

@implementation YumiMediationVideoAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDPlayableAds
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

    
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    
}

#pragma mark - PlayableAdsDelegate


@end
