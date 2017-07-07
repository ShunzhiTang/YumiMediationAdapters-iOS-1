//
//  YumiMediationInterstitialAdapterNativeGDT.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import "YumiMediationInterstitialAdapterNativeGDT.h"
#import <YumiCommon/YumiTool.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import "YumiAdsCustomViewController.h"
#import "GDTNativeAd.h"
#import <YumiCommon/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeGDT ()<YumiAdsCustomViewControllerDelegate,GDTNativeAdDelegate>

@property (nonatomic)GDTNativeAd *nativeAd;
@property (nonatomic) GDTNativeAdData *currentAd;
@property (nonatomic) NSArray *data;
@property (nonatomic) YumiAdsCustomViewController  *interstitial;

@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;

@end

@implementation YumiMediationInterstitialAdapterNativeGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDGDTNative
                                                             requestType:YumiMediationSDKAdRequest];
}

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


@end
