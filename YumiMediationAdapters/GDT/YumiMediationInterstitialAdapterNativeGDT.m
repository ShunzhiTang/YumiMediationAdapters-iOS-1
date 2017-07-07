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

#pragma mark :private method
- (void)requestInterstitialAdTemplate {
    NSString *fileName = [NSString stringWithFormat:@"inter%@", self.provider.data.providerID];
    
    self.templateManager =
    [[YumiBannerViewTemplateManager alloc] initWithGeneralTemplate:self.provider.data.generalTemplate
                                                 landscapeTemplate:self.provider.data.landscapeTemplate
                                                  verticalTemplate:self.provider.data.verticalTemplate
                                                  saveTemplateName:fileName];
    
    __weak typeof(self) weakSelf = self;
    [self.templateManager fetchMediationTemplateSuccess:^(YumiMediationTemplateModel *_Nullable templateModel) {
        weakSelf.templateModel = templateModel;
    }
                                                failure:^(NSError *_Nonnull error) {
                                                    [[YumiLogger stdLogger] log:kLogLevelError message:[error localizedDescription]];
                                                }];
    
    self.currentID = [self.templateManager getCurrentNativeTemplate].templateID;
}

- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *YumiMediationSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiMediationSDK"];
    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];
    
    return strPath;
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
