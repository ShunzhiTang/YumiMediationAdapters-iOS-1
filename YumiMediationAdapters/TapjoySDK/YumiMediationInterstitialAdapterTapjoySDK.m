//
//  YumiMediationInterstitialAdapterTapjoySDK.m
//  Pods
//
//  Created by generator on 28/06/2019.
//
//

#import "YumiMediationInterstitialAdapterTapjoySDK.h"

@interface YumiMediationInterstitialAdapterTapjoySDK ()

@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterTapjoySDK

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDTapjoy
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    // TODO: set code

    return self;
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
