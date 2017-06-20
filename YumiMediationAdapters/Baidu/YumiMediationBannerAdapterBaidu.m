//
//  YumiMediationBannerAdapterBaidu.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterBaidu.h"
#import "YumiMediationAdapterRegistry.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>

@interface YumiMediationBannerAdapterBaidu () <BaiduMobAdViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) BaiduMobAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10022"
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    [BaiduMobAdSetting sharedInstance].supportHttps = YES;
    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {

    CGSize adSize = isiPad ? kBaiduAdViewBanner728x90 : kBaiduAdViewBanner320x48;
    CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);
    _bannerView = [[BaiduMobAdView alloc] init];
    _bannerView.AdType = BaiduMobAdViewTypeBanner;
    _bannerView.delegate = self;
    _bannerView.AdUnitTag = self.provider.data.key2;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bannerView.frame = adFrame;
        [self.bannerView start];
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
