//
//  YumiMediationBannerAdapterBaidu.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterBaidu.h"
#import "YumiMediationAdapterConstructorRegistry.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>

@implementation YumiMediationBannerAdapterBaiduConstructor

+ (void)load {
    [[YumiMediationAdapterConstructorRegistry registry] registerBannerAdapterConstructor:[self new]
                                                                           forProviderID:@"10022"
                                                                             requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)createAdapterWithProvider:(YumiMediationBannerProvider *)provider
                                                   delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    return [[YumiMediationBannerAdapterBaidu alloc] initWithYumiMediationAdProvider:provider delegate:delegate];
}

@end

@interface YumiMediationBannerAdapterBaidu () <BaiduMobAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) BaiduMobAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterBaidu

- (instancetype)initWithYumiMediationAdProvider:(YumiMediationBannerProvider *)provider
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bannerView.frame = adFrame;
        [self.bannerView start];
    });
}


#pragma mark -  BaiduMobAdViewDelegate

- (NSString *)publisherId{
    return self.provider.data.key1;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview{
    
    [self.delegate adapter:self didReceiveAd:adview];
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason{
    
    NSString *errorReason = @"baidu not ad";
    
    if (reason == BaiduMobFailReason_EXCEPTION) {
        errorReason = @"network or other error";
    }else if(reason == BaiduMobFailReason_FRAME){
         errorReason = @"baidu ad size exception";
    }
    [self.delegate  adapter:self didFailToReceiveAd:errorReason];
}

- (void)didAdImpressed{

}

- (void)didAdClicked{
    [self.delegate adapter:self didClick:self.bannerView];
}

- (void)didDismissLandingPage{

}

#pragma mark - Getters
- (BaiduMobAdView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[BaiduMobAdView alloc] init];
         _bannerView.AdType = BaiduMobAdViewTypeBanner;
        _bannerView.delegate = self;
         _bannerView.AdUnitTag = self.provider.data.key2;
    }

    return _bannerView;
}

@end
