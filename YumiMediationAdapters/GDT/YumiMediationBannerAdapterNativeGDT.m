//
//  YumiMediationBannerAdapterNativeGDT.m
//  Pods
//
//  Created by generator on 27/06/2017.
//
//

#import "YumiMediationBannerAdapterNativeGDT.h"
#import "GDTNativeAd.h"
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterNativeGDT () <YumiMediationBannerAdapter, GDTNativeAdDelegate, UIWebViewDelegate>

@property (nonatomic) GDTNativeAd *nativeAd;
@property (nonatomic) NSArray *data;
@property (nonatomic) GDTNativeAdData *currentAd;
@property (nonatomic) UIWebView *webView;
@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;

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

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // request remote template
    [self requestBannerViewAdTemplate];

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    CGRect adframe = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // webView init
        strongSelf.webView = [[UIWebView alloc] initWithFrame:adframe];
        strongSelf.webView.delegate = strongSelf;
        strongSelf.webView.scrollView.scrollEnabled = NO;
        // nativeAD init
        strongSelf.nativeAd = [[GDTNativeAd alloc] initWithAppkey:strongSelf.provider.data.key1
                                                      placementId:strongSelf.provider.data.key2];
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
            [self.webView loadHTMLString:str baseURL:nil];
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

    [self.webView loadHTMLString:str baseURL:nil];
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

#pragma mark : - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self.nativeAd clickAd:self.currentAd];
        [self.delegate adapter:self didClick:self.webView on:CGPointZero withTemplateID:(int)self.currentID];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.nativeAd attachAd:self.currentAd toView:webView];
    [self.delegate adapter:self didReceiveAd:self.webView withTemplateID:(int)self.currentID];
}

@end
