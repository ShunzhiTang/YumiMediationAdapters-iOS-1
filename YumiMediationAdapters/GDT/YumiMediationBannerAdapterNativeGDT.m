//
//  YumiMediationBannerAdapterNativeGDT.m
//  Pods
//
//  Created by generator on 27/06/2017.
//
//

#import "YumiMediationBannerAdapterNativeGDT.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterNativeGDT () <YumiMediationBannerAdapter, GDTNativeExpressAdDelegete>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

// 原生模板广告
@property (nonatomic) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic) GDTNativeExpressAdView *expressView;

@end

@implementation YumiMediationBannerAdapterNativeGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDTNative
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.isSmartBanner) {
        CGSize size = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
        adSize = size;
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = CGSizeMake(300, 250);
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

#pragma mark : GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd
                               views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {

    if (views.count == 0) {
        [self.delegate adapter:self didFailToReceiveAd:@"gdt load fail"];
        return;
    }

    self.expressView = [views objectAtIndex:0];
    [self.expressView removeFromSuperview];

    self.expressView.controller = [self.delegate rootViewControllerForPresentingModalView];
    [self.expressView render];

    [self.delegate adapter:self didReceiveAd:self.expressView];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self didClick:self.expressView];
}

- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self didPresentInternalBrowser:self.expressView];
}
- (void)nativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self didDissmissInternalBrowser:self.expressView];
}
@end
