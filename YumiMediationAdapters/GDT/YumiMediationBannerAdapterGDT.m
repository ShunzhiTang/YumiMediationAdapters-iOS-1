//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by shunzhiTang 19/6/2017.
//
//
#import "YumiMediationBannerAdapterGDT.h"
#import "GDTMobBannerView.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterGDT () <GDTMobBannerViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) GDTMobBannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDT
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    CGSize adSize = isiPad ? GDTMOB_AD_SUGGEST_SIZE_728x90 : GDTMOB_AD_SUGGEST_SIZE_320x50;
    CGRect adframe = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView = [[GDTMobBannerView alloc] initWithFrame:adframe
                                                                 appkey:strongSelf.provider.data.key1
                                                            placementId:strongSelf.provider.data.key2];
        [strongSelf.bannerView setCurrentViewController:[strongSelf.delegate rootViewControllerForPresentingModalView]];
        strongSelf.bannerView.interval = 0;
        strongSelf.bannerView.isAnimationOn = NO;
        strongSelf.bannerView.showCloseBtn = NO;
        strongSelf.bannerView.delegate = self;

        [strongSelf.bannerView loadAdAndShow];
    });
}

#pragma mark - GDTMobBannerViewDelegate

- (void)bannerViewDidReceived {
    [self.delegate adapter:self didReceiveAd:self.bannerView];
}

- (void)bannerViewFailToReceived:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)bannerViewClicked {
    [self.delegate adapter:self didClick:self.bannerView];
}

@end
