//
//  YumiMediationInterstitialAdapterNativeGDT.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import "YumiMediationInterstitialAdapterNativeGDT.h"
#import "GDTNativeAd.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "YumiGDTAdapterInterstitialViewController.h"
#import <YumiMediationSDK/YumiAdsWKCustomViewController.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterNativeGDT () <GDTNativeExpressAdDelegete>

// native express
@property (nonatomic) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic) GDTNativeExpressAdView *expressView;

@property (nonatomic) YumiGDTAdapterInterstitialViewController *interstitialVc;
@property (nonatomic, assign) BOOL isInterstitialReady;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic) UIViewController *rootViewController;

@end

@implementation YumiMediationInterstitialAdapterNativeGDT
- (NSString *)networkVersion {
    return @"4.10.13";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDGDTNative
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark :  private  method
- (YumiGDTAdapterInterstitialViewController *)getNibResourceFromCustomBundle:(NSString *)name type:(NSString *)type {

    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"YumiMediationGDT" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];

    YumiGDTAdapterInterstitialViewController *vc =
        [[YumiGDTAdapterInterstitialViewController alloc] initWithNibName:name bundle:bundle];
    if (vc == nil) {
        NSLog(@"GDT 加载素材失败");
    }
    return vc;
}
- (void)closeGDTIntestitial {
    [[YumiLogger stdLogger] debug:@"---GDT native interstitial closed"];
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];

    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
    self.interstitialVc = nil;
    self.isInterstitialReady = NO;
    self.nativeExpressAd = nil;
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---GDT native interstitial start request"];
    self.isInterstitialReady = NO;
    YumiTool *tool = [YumiTool sharedTool];
    CGSize adSize = CGSizeMake(ScreenWidth, 300);
    if (![tool isInterfaceOrientationPortrait]) {
        adSize = CGSizeMake(ScreenHeight, 300);
    }
    if ([tool isiPad]) {
        adSize = CGSizeMake(500, 500);
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:weakSelf.provider.data.key1
                                                                 placementId:weakSelf.provider.data.key2
                                                                      adSize:adSize];
        weakSelf.nativeExpressAd.delegate = self;

        // The number of times a request has been requested
        [weakSelf.nativeExpressAd loadAd:1];
    });
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---GDT native interstitial cheack ready status.%d",self.isInterstitialReady]];
    return self.isInterstitialReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---GDT native interstitial present"];
    __weak __typeof(self) weakSelf = self;
    self.rootViewController = rootViewController;
    self.interstitialVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [rootViewController
        presentViewController:self.interstitialVc
                     animated:YES
                   completion:^{
                       [weakSelf.delegate coreAdapter:weakSelf didOpenCoreAd:nil adType:weakSelf.adType];
                       [weakSelf.delegate coreAdapter:weakSelf didStartPlayingAd:nil adType:weakSelf.adType];
                   }];
}

#pragma mark : - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd
                               views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {

    if (views.count == 0) {
        [self.delegate coreAdapter:self
                            coreAd:self.interstitialVc
                     didFailToLoad:@"gdt failed to load"
                            adType:self.adType];
        return;
    }

    self.expressView = [views objectAtIndex:0];
    [self.expressView removeFromSuperview];

    self.expressView.controller = self.interstitialVc;
    [self.expressView render];

    self.isInterstitialReady = YES;
    __weak typeof(self) weakSelf = self;
    self.interstitialVc.closeBlock = ^{
        [weakSelf closeGDTIntestitial];
    };
    CGSize adSize = self.expressView.frame.size;

    [self.interstitialVc.view addSubview:self.expressView];
    [self.expressView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
        make.centerY.equalTo(self.interstitialVc.view.mas_centerY);
        make.centerX.equalTo(self.interstitialVc.view.mas_centerX);
        make.height.mas_equalTo(adSize.height);
        make.width.mas_equalTo(adSize.width);
    }];
    [[YumiLogger stdLogger] debug:@"---GDT native interstitial did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:self.interstitialVc adType:self.adType];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    self.isInterstitialReady = NO;
    [self.delegate coreAdapter:self coreAd:self.interstitialVc didFailToLoad:@"gdt failed to load" adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---GDT native interstitial did fail to load"];
}
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate coreAdapter:self didClickCoreAd:self.interstitialVc adType:self.adType];
}
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
}
- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self closeGDTIntestitial];
}

#pragma mark : getter method
- (YumiGDTAdapterInterstitialViewController *)interstitialVc {
    if (!_interstitialVc) {
        _interstitialVc = [self getNibResourceFromCustomBundle:@"YumiGDTAdapterInterstitialViewController" type:@"xib"];
    }
    return _interstitialVc;
}
@end
