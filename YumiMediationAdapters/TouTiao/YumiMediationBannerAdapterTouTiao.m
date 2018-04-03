//
//  YumiMediationBannerAdapterTouTiao.m
//  Pods
//
//  Created by generator on 02/11/2017.
//
//

#import "YumiMediationBannerAdapterTouTiao.h"
#import <WMAdSDK/WMAdSDKManager.h>
#import <WMAdSDK/WMBannerAdView.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterTouTiao () <YumiMediationBannerAdapter, WMBannerAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) WMBannerAdView *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterTouTiao

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDTouTiao
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [WMAdSDKManager setAppID:self.provider.data.key1];

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {

    WMSize *ttSize =
        isiPad ? [WMSize sizeBy:WMProposalSize_Banner600_300] : [WMSize sizeBy:WMProposalSize_Banner600_100];

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.isSmartBanner) {

        adSize = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        ttSize = [WMSize sizeBy:WMProposalSize_Banner600_500];
        adSize = CGSizeMake(300, 250);
    }

    CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

        weakSelf.bannerView =
            [[WMBannerAdView alloc] initWithSlotID:weakSelf.provider.data.key2
                                              size:ttSize
                                rootViewController:[weakSelf.delegate rootViewControllerForPresentingModalView]];
        weakSelf.bannerView.delegate = weakSelf;
        weakSelf.bannerView.frame = adFrame;
        weakSelf.bannerView.dislikeButton.hidden = YES;

        [weakSelf.bannerView loadAdData];
    });
}

#pragma mark :- WMBannerAdViewDelegate
- (void)bannerAdViewDidLoad:(WMBannerAdView *)bannerAdView WithAdmodel:(WMNativeAd *_Nullable)nativeAd {
    [self.delegate adapter:self didReceiveAd:bannerAdView];
}

- (void)bannerAdViewDidClick:(WMBannerAdView *)bannerAdView WithAdmodel:(WMNativeAd *_Nullable)nativeAd {
    [self.delegate adapter:self didClick:bannerAdView];
}

- (void)bannerAdView:(WMBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

@end
