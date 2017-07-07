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
    // request remote template
    [self requestInterstitialAdTemplate];
    
    CGRect gdtFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    NSDictionary *closeBtnFrame = @{
                                    @"closeButton_w" : @(self.provider.data.closeButton.clickAreaWidth),
                                    @"closeButton_h" : @(self.provider.data.closeButton.clickAreaHeight),
                                    @"closeImage_w" : @(self.provider.data.closeButton.pictureWidth),
                                    @"closeImage_h" : @(self.provider.data.closeButton.pictureHeight)
                                    };
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.interstitial = [[YumiAdsCustomViewController alloc]
                                 initYumiAdsCustomViewControllerWith:gdtFrame
                                 clickType:YumiAdsClickTypeDownload
                                 closeBtnPosition:weakSelf.provider.data.closeButton.position
                                 closeBtnFrame:closeBtnFrame
                                 isAPI:YES
                                 delegate:weakSelf];
        weakSelf.interstitial.isNativeInterstitialGDT = YES;
        
        weakSelf.nativeAd = [[GDTNativeAd alloc] initWithAppkey:weakSelf.provider.data.key1 placementId:weakSelf.provider.data.key2];
        weakSelf.nativeAd.controller = weakSelf.interstitial;
        weakSelf.nativeAd.delegate = weakSelf;
        
        [weakSelf.nativeAd loadAd:1];
    });
    
}

- (BOOL)isReady {
    return self.interstitial.isReady;
}

- (void)present {
     [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
    
    [self.nativeAd attachAd:self.currentAd toView:self.interstitial.customView];
}

#pragma mark: - GDTNativeAdDelegate
-  (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray{
    if (!nativeAdDataArray || ![nativeAdDataArray objectAtIndex:0]) {
        [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"GDT no ad"];
        return;
    }
    
    _data = nativeAdDataArray;
     _currentAd = [_data objectAtIndex:0];
    
    if (!_currentAd.properties || ![_currentAd.properties objectForKey:GDTNativeAdDataKeyImgUrl] ||
        ![_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc]) {
        [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"GDT no ad"];
        return;
    }
    
    NSString *bigImg = [_currentAd.properties objectForKey:GDTNativeAdDataKeyImgUrl];
    NSString *iconImg = [_currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl];
    NSString *title = [_currentAd.properties objectForKey:GDTNativeAdDataKeyTitle];
    NSString *desc = [_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc];
    NSString *star = [[_currentAd.properties objectForKey:GDTNativeAdDataKeyAppRating] stringValue];
    if ([star isEqualToString:@""] || !star) {
        star = @"3.5";
    }
    
    NSString *interstitialPath;
    if ([[YumiTool sharedTool] isInterfaceOrientationPortrait]) {
        interstitialPath = [self resourceNamedFromCustomBundle:@"cp-native"];
    } else {
        interstitialPath = [self resourceNamedFromCustomBundle:@"cp-native-lan"];
    }

    NSData *interstitialData = [NSData dataWithContentsOfFile:interstitialPath];
    NSString *interstitialStr = [[NSString alloc] initWithData:interstitialData encoding:NSUTF8StringEncoding];
    
    if ([[YumiTool sharedTool] isInterfaceOrientationPortrait]) {
        interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"100%", @"100%", @"100%",
                           @"70%", @"100%", @"100%", @"100%", @"50%", bigImg, @"100%",
                           iconImg, title, desc, star, @"about:blank"];
    } else {
        interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"50%", @"100%", @"100%",
                           @"20%", @"2%", @"74%", @"100%", @"100%", @"65%", @"5%", @"30%",
                           iconImg, title, star, bigImg, @"100%", desc, @"about:blank"];
    }
    
    if (self.templateModel) {
        NSString *templateID = [NSString stringWithFormat:@"%d", self.templateModel.templateID];
        NSString *currentID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:self.currentID]];
        if (![templateID isEqualToString:currentID] || !self.templateModel.htmlString) {
            [self.interstitial loadHTMLString:interstitialStr];
            return;
        }
        
        interstitialStr = self.templateModel.htmlString;
        interstitialStr = [self.templateManager
               replaceHtmlCharactersWithString:interstitialStr
               iconURL:iconImg
               title:title
               description:desc
               imageURL:bigImg
               hyperlinkURL:@"跳转"];
    }
    
    [self.interstitial loadHTMLString:interstitialStr];
    
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
}

- (void)nativeAdClosed{
        [self.interstitial closeButtonPressed];
}
- (void)nativeAdWillPresentScreen{
}

- (void)nativeAdApplicationWillEnterBackground{
}

#pragma mark: YumiAdsCustomViewControllerDelegate
- (void)yumiAdsCustomViewControllerDidReceivedAd:(UIViewController *)viewController {
    
    [self.delegate adapter:self didReceiveInterstitialAd:self.interstitial];
}

- (void)yumiAdsCustomViewController:(UIViewController *)viewController didFailToReceiveAdWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
}

- (void)didClickOnYumiAdsCustomViewController:(UIViewController *)viewController point:(CGPoint)point {
    [self.nativeAd clickAd:self.currentAd];
   
    [self.delegate adapter:self didClickInterstitialAd:self.interstitial on:point];
}

- (void)yumiAdsCustomViewControllerDidPresent:(UIViewController *)viewController {
    
    [self.delegate adapter:self willPresentScreen:self.interstitial];
}

- (void)yumiAdsCustomViewControllerDidClosed:(UIViewController *)viewController {
    [self.delegate adapter:self willDismissScreen:self.interstitial];
}

@end
