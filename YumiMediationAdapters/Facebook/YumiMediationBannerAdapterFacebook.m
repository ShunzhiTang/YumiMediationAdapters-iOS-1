//
//  YumiMediationBannerAdapterFacebook.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterFacebook.h"
#import "YumiMediationAdapterRegistry.h"
#import <FBAudienceNetwork/FBAdView.h>

@interface YumiMediationBannerAdapterFacebook () <FBAdViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) FBAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10007"
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

    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    CGRect adframe = CGRectMake(0, 0, viewSize.width, adSize.size.height);

    dispatch_async(dispatch_get_main_queue(), ^{
        //@"YOUR_PLACEMENT_ID"
        self.bannerView =
                [[FBAdView alloc] initWithPlacementID:self.provider.data.key1
                                               adSize:adSize
                                   rootViewController:[self.delegate rootViewControllerForPresentingBannerView]];
        self.bannerView.delegate = self;
        self.bannerView.frame = adframe;
        [self.bannerView loadAd];

    });
}

#pragma mark -  FBAdViewDelegate
- (void)adViewDidClick:(FBAdView *)adView {
    [self.delegate adapter:self didClick:adView];
}

- (void)adViewDidLoad:(FBAdView *)adView {

    [self.delegate adapter:self didReceiveAd:adView];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

@end
