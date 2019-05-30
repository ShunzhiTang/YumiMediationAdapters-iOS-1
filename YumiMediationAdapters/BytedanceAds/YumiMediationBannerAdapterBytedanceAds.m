//
//  YumiMediationBannerAdapterBytedanceAds.m
//  Pods
//
//  Created by generator on 23/05/2019.
//
//

#import "YumiMediationBannerAdapterBytedanceAds.h"
#import <BUAdSDK/BUAdSDK.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterBytedanceAds () <YumiMediationBannerAdapter, BUBannerAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@property (nonatomic, strong) BUBannerAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterBytedanceAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBytedanceAds
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [BUAdSDKManager setAppID:provider.data.key1];

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {

    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
            weakSelf.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
            [weakSelf.delegate adapter:weakSelf
                    didFailToReceiveAd:@"BytedanceAds not support kYumiMediationAdViewSmartBannerPortrait or "
                                       @"kYumiMediationAdViewSmartBannerLandscape"];
            return;
        }
        CGSize requestSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
        if (weakSelf.isSmartBanner) {
            requestSize =
                [[YumiTool sharedTool] fetchBannerAdSizeWith:weakSelf.bannerSize smartBanner:weakSelf.isSmartBanner];
        }
        BUSize *adSize = [[BUSize alloc] init];
        adSize.width = requestSize.width;
        adSize.height = requestSize.height;

        if (weakSelf.bannerSize == kYumiMediationAdViewBanner300x250) {
            adSize = [BUSize sizeBy:BUProposalSize_Banner600_500];
        }

        CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);

        weakSelf.bannerView =
            [[BUBannerAdView alloc] initWithSlotID:weakSelf.provider.data.key2
                                              size:adSize
                                rootViewController:[weakSelf.delegate rootViewControllerForPresentingModalView]];
        weakSelf.bannerView.frame = adFrame;
        weakSelf.bannerView.delegate = weakSelf;

        [weakSelf.bannerView loadAdData];
    });
}

#pragma mark : BUBannerAdViewDelegate
- (void)bannerAdViewDidLoad:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
    [self.delegate adapter:self didReceiveAd:bannerAdView];
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)bannerAdViewDidBecomVisible:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
}

- (void)bannerAdViewDidClick:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
    [self.delegate adapter:self didClick:bannerAdView];
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView
    dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
}
@end
