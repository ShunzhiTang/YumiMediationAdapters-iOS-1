//
//  YumiMediationInterstitialAdapterNativeInMobi.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/29.
//

#import "YumiMediationInterstitialAdapterNativeInMobi.h"
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeInMobi ()


@end

@implementation YumiMediationInterstitialAdapterNativeInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDInMobiNative
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark :private method


#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)requestAd {

}

- (BOOL)isReady {
    
}

- (void)present {
    
}

#pragma mark : - 


@end
