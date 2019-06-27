//
//  YumiMediationBannerAdapterNativeInMobi.m
//  Pods
//
//  Created by  generator on 2017/6/27.
//
//

#import "YumiMediationBannerAdapterNativeInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiAdsWKCustomView.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterNativeInMobi () <YumiMediationBannerAdapter, IMNativeDelegate,
                                                      YumiAdsWKCustomViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) IMNative *nativeAd;
@property (nonatomic) NSString *nativeContent;
@property (nonatomic) YumiAdsWKCustomView *webView;
@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterNativeInMobi
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDInMobiNative
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
            [[YumiLogger stdLogger] log:kYumiLogLevelError message:[error localizedDescription]];
        }];

    self.currentID = [self.templateManager getCurrentNativeTemplate].templateID;
}

- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *YumiMediationSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiMediationSDK"];
    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];

    return strPath;
}

#pragma mark : - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    NSDictionary *consentDict = nil;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        consentDict = @{IM_GDPR_CONSENT_AVAILABLE : @(YES)};
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        consentDict = @{IM_GDPR_CONSENT_AVAILABLE : @(NO)};
    }
    
    // Initialize InMobi SDK with your account ID
    [IMSdk initWithAccountID:provider.data.key1 consentDictionary:consentDict];
    // Set log level to Debug
    [IMSdk setLogLevel:kIMSDKLogLevelNone];
    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @(YES)}];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @(NO)}];
    }
    
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"inmobi-ys not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    [self requestBannerViewAdTemplate];

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.isSmartBanner) {
        adSize = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = CGSizeMake(300, 250);
    }
    CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // YumiAdsWKCustomView init
        strongSelf.webView = [[YumiAdsWKCustomView alloc] initYumiAdsWKCustomViewWith:adFrame
                                                                            clickType:YumiAdsClickTypeOpenSystemSafari
                                                                             logoType:YumiAdsLogoCommon
                                                                             delegate:strongSelf];
        // nativeAD init
        strongSelf.nativeAd =
            [[IMNative alloc] initWithPlacementId:[strongSelf.provider.data.key2 longLongValue] delegate:strongSelf];

        [strongSelf.nativeAd load];
    });
}

#pragma mark : - IMNativeDelegate
- (void)nativeDidFinishLoading:(IMNative *)native {
    self.nativeContent = native.customAdContent;
    NSDictionary *jsonDict = nil;
    if (self.nativeContent != nil) {
        NSData *data = [self.nativeContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (!jsonDict) {
        return;
    }

    NSDictionary *iconDict = jsonDict[@"icon"];
    NSDictionary *screenshotsDict = jsonDict[@"screenshots"];

    if (!iconDict) {
        [self.delegate adapter:self didFailToReceiveAd:@"inMobi no ad"];
        return;
    }

    NSString *path = [self resourceNamedFromCustomBundle:@"native-banner"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = [NSString stringWithFormat:str, @"100%", @"100%", @"50%", @"100%", @"100%", @"100%", @"100%",
                                     jsonDict[@"landingURL"], iconDict[@"url"], jsonDict[@"title"],
                                     jsonDict[@"description"], @"%"];
    if (self.templateModel) {
        NSString *templateID = [NSString stringWithFormat:@"%d", self.templateModel.templateID];
        NSString *currentID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:self.currentID]];
        if (![templateID isEqualToString:currentID] || !self.templateModel.htmlString) {
            [self.webView loadHTMLString:str];
            return;
        }
        str = self.templateModel.htmlString;
        str = [self.templateManager replaceHtmlCharactersWithString:str
                                                            iconURL:iconDict[@"url"]
                                                              title:jsonDict[@"title"]
                                                        description:jsonDict[@"description"]
                                                           imageURL:screenshotsDict[@"url"]
                                                       hyperlinkURL:jsonDict[@"landingURL"]];
    }

    [self.webView loadHTMLString:str];
}
- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}
- (void)nativeWillPresentScreen:(IMNative *)native {
}
- (void)nativeDidPresentScreen:(IMNative *)native {
}
- (void)nativeWillDismissScreen:(IMNative *)native {
}
- (void)nativeDidDismissScreen:(IMNative *)native {
}
- (void)userWillLeaveApplicationFromNative:(IMNative *)native {
}
- (void)nativeAdImpressed:(IMNative *)native {
}

#pragma mark : - YumiAdsWKCustomViewDelegate
- (void)yumiAdsWKCustomViewDidFinishLoad:(WKWebView *)webView {
    [self.delegate adapter:self didReceiveAd:self.webView withTemplateID:(int)self.currentID];
}
- (void)yumiAdsWKCustomView:(WKWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)didClickOnYumiAdsWKCustomView:(WKWebView *)webView point:(CGPoint)point {
    [self.delegate adapter:self didClick:self.webView on:point withTemplateID:(int)self.currentID];
}
- (UIViewController *)rootViewControllerForPresentYumiAdsWKCustomView {
    return [self.delegate rootViewControllerForPresentingModalView];
}

@end
