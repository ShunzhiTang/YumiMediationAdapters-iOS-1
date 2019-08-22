//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by shunzhiTang 19/6/2017.
//
//
#import "YumiMediationBannerAdapterGDT.h"
#import "GDTUnifiedBannerView.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterGDT () <GDTUnifiedBannerViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GDTUnifiedBannerView *unifiedBannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDT
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

- (NSString*)networkVersion {
    return @"4.10.3";
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"gdt not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self didFailToReceiveAd:@"GDT not support kYumiMediationAdViewBanner300x250"];
        return;
    }

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.isSmartBanner) {
        adSize = [[YumiTool sharedTool] fetchBannerAdSizeWith:self.bannerSize smartBanner:self.isSmartBanner];
    }

    CGRect adframe = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.unifiedBannerView =
            [[GDTUnifiedBannerView alloc] initWithFrame:adframe
                                                  appId:weakSelf.provider.data.key1 ?: @""
                                            placementId:weakSelf.provider.data.key2 ?: @""
                                         viewController:[weakSelf.delegate rootViewControllerForPresentingModalView]];
        weakSelf.unifiedBannerView.animated = NO;
        weakSelf.unifiedBannerView.autoSwitchInterval = (int)weakSelf.provider.data.autoRefreshInterval;
        weakSelf.unifiedBannerView.delegate = weakSelf;

        [weakSelf.unifiedBannerView loadAdAndShow];
    });
}

#pragma mark - GDTUnifiedBannerViewDelegate
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.delegate adapter:self didReceiveAd:self.unifiedBannerView];
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.delegate adapter:self didClick:self.unifiedBannerView];
}

@end
