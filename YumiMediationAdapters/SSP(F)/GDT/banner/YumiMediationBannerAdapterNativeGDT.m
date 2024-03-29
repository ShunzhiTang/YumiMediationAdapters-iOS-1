//
//  YumiMediationBannerAdapterNativeGDT.m
//  Pods
//
//  Created by generator on 27/06/2017.
//
//

#import "YumiMediationBannerAdapterNativeGDT.h"
#import "GDTNativeAd.h"
#import <YumiAdSDK/YumiAdsWKCustomView.h>
#import <YumiAdSDK/YumiBannerViewTemplateManager.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>
#import <YumiAdSDK/YumiTool.h>

@interface YumiMediationBannerAdapterNativeGDT () <YumiMediationBannerAdapter, GDTNativeAdDelegate,
                                                   YumiAdsWKCustomViewDelegate>

@property (nonatomic) GDTNativeAd *nativeAd;
@property (nonatomic) NSArray *data;
@property (nonatomic) GDTNativeAdData *currentAd;
@property (nonatomic) YumiAdsWKCustomView *webView;
@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterNativeGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDTNative
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark :private method
- (void)requestBannerViewAdTemplate {
    NSString *fileName = [NSString stringWithFormat:@"banner%@", self.provider.data.providerID];
    if (self.provider.data.generalTemplate == nil && self.provider.data.landscapeTemplate == nil && self.provider.data.verticalTemplate == nil) {
        return;
    }
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
            [[YumiLogger stdLogger] log:kYumiLogLevelError message:[error localizedDescription]];
        }];

    self.currentID = [self.templateManager getCurrentNativeTemplate].templateID;
}

- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *YumiMediationSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiMediationSDK"];
    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];

    return strPath;
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (NSString *)networkVersion {
    return @"4.10.19";
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"GDT-ys not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    // request remote template
    [self requestBannerViewAdTemplate];

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.isSmartBanner) {
        adSize = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = CGSizeMake(300, 250);
    }
    CGRect adframe = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // webView init
        strongSelf.webView = [[YumiAdsWKCustomView alloc] initYumiAdsWKCustomViewWith:adframe
                                                                            clickType:YumiAdsClickTypeOpenSystemSafari
                                                                             logoType:YumiAdsLogoGDT
                                                                             delegate:strongSelf];
        // nativeAD init
        strongSelf.nativeAd = [[GDTNativeAd alloc] initWithAppId:strongSelf.provider.data.key1 ?: @""
                                                     placementId:strongSelf.provider.data.key2 ?: @""];
        strongSelf.nativeAd.controller = strongSelf.delegate.rootViewControllerForPresentingModalView;
        strongSelf.nativeAd.delegate = strongSelf;

        [strongSelf.nativeAd loadAd:1]; // The number of times a request has been requested “1”
    });
}

#pragma mark : GDTNativeAdDelegate
- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        return;
    }
    self.data = nativeAdDataArray;
    self.currentAd = [self.data objectAtIndex:0];

    if (![self.currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl] ||
        ![self.currentAd.properties objectForKey:GDTNativeAdDataKeyDesc]) {
        [self.delegate adapter:self didFailToReceiveAd:@"GDT no ad"];
        return;
    }

    NSString *path = [self resourceNamedFromCustomBundle:@"native-banner"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = [NSString stringWithFormat:str, @"100%", @"100%", @"50%", @"100%", @"100%", @"100%", @"100%", @"跳转",
                                     [self.currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl],
                                     [self.currentAd.properties objectForKey:GDTNativeAdDataKeyTitle],
                                     [self.currentAd.properties objectForKey:GDTNativeAdDataKeyDesc], @"%"];
    if (self.templateModel) {
        NSString *templateID = [NSString stringWithFormat:@"%d", self.templateModel.templateID];
        NSString *currentID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:self.currentID]];
        if (![templateID isEqualToString:currentID] || !self.templateModel.htmlString) {
            [self.webView loadHTMLString:str];
            return;
        }

        str = self.templateModel.htmlString;
        str = [self.templateManager
            replaceHtmlCharactersWithString:str
                                    iconURL:[self.currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl]
                                      title:[self.currentAd.properties objectForKey:GDTNativeAdDataKeyTitle]
                                description:[self.currentAd.properties objectForKey:GDTNativeAdDataKeyDesc]
                                   imageURL:@"大图"
                               hyperlinkURL:@"跳转"];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.webView loadHTMLString:str];
    });
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

#pragma mark : - YumiAdsWKCustomViewDelegate
- (void)didClickOnYumiAdsWKCustomView:(WKWebView *)webView point:(CGPoint)point {
    [self.nativeAd clickAd:self.currentAd];
    [self.delegate adapter:self didClick:self.webView on:point withTemplateID:(int)self.currentID];
}

- (UIViewController *)rootViewControllerForPresentYumiAdsWKCustomView {
    return [self.delegate rootViewControllerForPresentingModalView];
}

- (void)yumiAdsWKCustomView:(WKWebView *)webView didFailLoadWithError:(nonnull NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)yumiAdsWKCustomViewDidFinishLoad:(WKWebView *)webView {
    [self.nativeAd attachAd:self.currentAd toView:webView];
    [self.delegate adapter:self didReceiveAd:self.webView withTemplateID:(int)self.currentID];
}

@end
