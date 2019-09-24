//
//  YumiMediationBannerAdapterBaidu.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterBaidu.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterBaidu () <BaiduMobAdViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) BaiduMobAdView *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBaidu
                                                       requestType:YumiMediationSDKAdRequest];
}

- (void)dealloc {
    if (self.bannerView) {
        self.bannerView.delegate = nil;
        self.bannerView = nil;
    }
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    [BaiduMobAdSetting sharedInstance].supportHttps = YES;
    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (NSString *)networkVersion {
    return @"4.6.7";
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = CGSizeMake(300, 250);
    }
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"baidu not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView = [[BaiduMobAdView alloc] init];
        strongSelf.bannerView.AdType = BaiduMobAdViewTypeBanner;
        strongSelf.bannerView.delegate = strongSelf;
        strongSelf.bannerView.AdUnitTag = strongSelf.provider.data.key2;
        strongSelf.bannerView.frame = adFrame;

        [strongSelf.bannerView start];
    });
}

#pragma mark -  BaiduMobAdViewDelegate

- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {

    [self.delegate adapter:self didReceiveAd:adview];
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {

    NSString *errorReason = @"baidu not ad";

    if (reason == BaiduMobFailReason_EXCEPTION) {
        errorReason = @"network or other error";
    } else if (reason == BaiduMobFailReason_FRAME) {
        errorReason = @"baidu ad size exception";
    }
    [self.delegate adapter:self didFailToReceiveAd:errorReason];
}

- (void)didAdImpressed {
}

- (void)didAdClicked {
    [self.delegate adapter:self didClick:self.bannerView];
}

- (void)didDismissLandingPage {
}

@end
