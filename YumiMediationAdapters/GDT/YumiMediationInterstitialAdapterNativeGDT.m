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

@interface YumiMediationInterstitialAdapterNativeGDT () <GDTNativeExpressAdDelegete>

// native express
@property (nonatomic) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic) GDTNativeExpressAdView *expressView;

@property (nonatomic) YumiGDTAdapterInterstitialViewController *interstitialVc;
@property (nonatomic, assign) BOOL isInterstitialReady;

@end

@implementation YumiMediationInterstitialAdapterNativeGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDGDTNative
                                                             requestType:YumiMediationSDKAdRequest];
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
    [[self.delegate rootViewControllerForPresentingModalView] dismissViewControllerAnimated:YES completion:nil];

    [self.delegate adapter:self willDismissScreen:self.interstitialVc];
    self.interstitialVc = nil;
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.isInterstitialReady = NO;
    return self;
}

- (void)requestAd {

    CGSize adSize = CGSizeMake(300, 300);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppkey:weakSelf.provider.data.key1
                                                                  placementId:weakSelf.provider.data.key2
                                                                       adSize:adSize];
        weakSelf.nativeExpressAd.delegate = self;

        // The number of times a request has been requested
        [weakSelf.nativeExpressAd loadAd:1];
    });
}

- (BOOL)isReady {
    return self.isInterstitialReady;
}

- (void)present {
    [[self.delegate rootViewControllerForPresentingModalView] presentViewController:self.interstitialVc
                                                                           animated:YES
                                                                         completion:nil];
}

#pragma mark : - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd
                               views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {

    if (views.count == 0) {
        [self.delegate adapter:self interstitialAd:self.interstitialVc didFailToReceive:@"gdt load fail"];
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

    [self.delegate adapter:self didReceiveInterstitialAd:self.interstitialVc];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    self.isInterstitialReady = NO;
    [self.delegate adapter:self interstitialAd:self.interstitialVc didFailToReceive:@"gdt load fail"];
}
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self didClickInterstitialAd:self.interstitialVc];
}
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self willPresentScreen:self.interstitialVc];
}
#pragma mark : getter method
- (YumiGDTAdapterInterstitialViewController *)interstitialVc {
    if (!_interstitialVc) {
        _interstitialVc = [self getNibResourceFromCustomBundle:@"YumiGDTAdapterInterstitialViewController" type:@"xib"];
    }
    return _interstitialVc;
}
@end
