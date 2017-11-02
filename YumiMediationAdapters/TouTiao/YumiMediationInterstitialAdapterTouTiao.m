//
//  YumiMediationInterstitialAdapterTouTiao.m
//  Pods
//
//  Created by generator on 02/11/2017.
//
//

#import "YumiMediationInterstitialAdapterTouTiao.h"

@interface YumiMediationInterstitialAdapterTouTiao ()

@end

@implementation YumiMediationInterstitialAdapterTouTiao

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDTouTiao
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    // TODO: setup code

    return self;
}

- (void)requestAd {
    // TODO: request ad
}

- (BOOL)isReady {
    // TODO: check if ready
    return YES;
}

- (void)present {
    UIViewController *rootViewController = [self.delegate rootViewControllerForPresentingModalView];
    // TODO: present interstitial ad with rootViewController
}

// TODO: implement third party sdk delegate and delegate to mediation sdk

@end
