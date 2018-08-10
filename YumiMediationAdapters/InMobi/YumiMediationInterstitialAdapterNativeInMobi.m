//
//  YumiMediationInterstitialAdapterNativeInMobi.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/29.
//

#import "YumiMediationInterstitialAdapterNativeInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiAdsWKCustomViewController.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeInMobi () <IMNativeDelegate, YumiAdsWKCustomViewControllerDelegate>

@property (nonatomic) IMNative *imnative;
@property (nonatomic) NSDictionary *imobeDict;
@property (nonatomic) YumiAdsWKCustomViewController *interstitial;

@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;

@end

@implementation YumiMediationInterstitialAdapterNativeInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDInMobiNative
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark :private method
- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *YumiMediationSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiMediationSDK"];
    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];

    return strPath;
}

- (void)createCustomViewControllerWith:(CGFloat)width height:(CGFloat)height {
    CGRect inmobiFrame = CGRectMake(0, 0, width, height);

    NSDictionary *closeBtnFrame = @{
        @"closeButton_w" : @(self.provider.data.closeButton.clickAreaWidth),
        @"closeButton_h" : @(self.provider.data.closeButton.clickAreaHeight),
        @"closeImage_w" : @(self.provider.data.closeButton.pictureWidth),
        @"closeImage_h" : @(self.provider.data.closeButton.pictureHeight)
    };

    self.interstitial = [[YumiAdsWKCustomViewController alloc]
        initYumiAdsWKCustomViewControllerWith:inmobiFrame
                                    clickType:YumiAdsClickTypeOpenSystem
                             closeBtnPosition:self.provider.data.closeButton.position
                                closeBtnFrame:closeBtnFrame
                                     logoType:YumiAdsLogoCommon
                                     delegate:self];
    self.interstitial.isNativeInterstitialGDT = NO;
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    dispatch_async(dispatch_get_main_queue(), ^{
        [IMSdk initWithAccountID:self.provider.data.key1];
        [IMSdk setLogLevel:kIMSDKLogLevelNone];
    });
    return self;
}

- (void)requestAd {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.imnative = [[IMNative alloc] initWithPlacementId:[self.provider.data.key2 longLongValue]];
        weakSelf.imnative.delegate = self;
        [weakSelf.imnative load];

    });
}

- (BOOL)isReady {

    return self.interstitial.isReady;
}

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];

    // inmobi present
    [IMNative bindNative:self.imnative toView:self.interstitial.customView];
}

#pragma mark : - IMNativeDelegate

- (void)nativeDidFinishLoading:(IMNative *)native {

    if (!native || !native.adContent) {
        [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"Inmobi native no ad"];
        return;
    }

    if (native.adContent != nil) {
        NSData *data = [native.adContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        self.imobeDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (!self.imobeDict || ![self.imobeDict objectForKey:@"screenshots"]) {
        [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"Inmobi native no ad"];
        return;
    }

    NSUInteger width = [[[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"width"] integerValue];
    NSUInteger height = [[[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"height"] integerValue];
    NSString *url = [[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"url"];
    NSString *clickUrl = [self.imobeDict objectForKey:@"landingURL"];

    if (!url || url.length == 0 || width == 0 || height == 0 || !clickUrl || clickUrl.length == 0) {
        [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"Inmobi native no ad"];
        return;
    }

    [self createCustomViewControllerWith:width height:height];

    NSString *interstitialPath = [self resourceNamedFromCustomBundle:@"cp-img"];

    NSData *interstitialData = [NSData dataWithContentsOfFile:interstitialPath];
    NSString *interstitialStr = [[NSString alloc] initWithData:interstitialData encoding:NSUTF8StringEncoding];

    interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"100%", @"100%", clickUrl, url];

    [self.interstitial loadHTMLString:interstitialStr];
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
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

#pragma mark : YumiAdsWKCustomViewControllerDelegate
- (void)yumiAdsWKCustomViewControllerDidReceivedAd:(UIViewController *)viewController {

    [self.delegate adapter:self
        didReceiveInterstitialAd:self.interstitial
               interstitialFrame:CGRectZero
                  withTemplateID:(int)self.currentID];
}

- (void)yumiAdsWKCustomViewController:(UIViewController *)viewController didFailToReceiveAdWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
}

- (void)didClickOnYumiAdsWKCustomViewController:(UIViewController *)viewController point:(CGPoint)point {
    // inmobi
    [self.imnative reportAdClick:self.imobeDict];

    [self.delegate adapter:self didClickInterstitialAd:self.interstitial on:point withTemplateID:(int)self.currentID];
}

- (void)yumiAdsWKCustomViewControllerDidPresent:(UIViewController *)viewController {

    [self.delegate adapter:self willPresentScreen:self.interstitial];
}

- (void)yumiAdsWKCustomViewControllerDidClosed:(UIViewController *)viewController {
    [self.delegate adapter:self willDismissScreen:self.interstitial];
}

@end
