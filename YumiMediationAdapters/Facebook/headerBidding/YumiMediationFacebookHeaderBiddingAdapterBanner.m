//
//  YumiMediationFacebookHeaderBiddingAdapterBanner.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/28.
//

#import "YumiMediationFacebookHeaderBiddingAdapterBanner.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBAdView.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationFacebookHeaderBiddingAdapterBanner () <FBAdViewDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) FBAdView *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@property (nonatomic) NSString *bidPayloadFromServer;
@end

@implementation YumiMediationFacebookHeaderBiddingAdapterBanner

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDFacebookHeaderBidding
                                                       requestType:YumiMediationSDKAdRequest];
}

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

- (void)setUpBidPayloadValue:(NSString *)bidPayload{
    self.bidPayloadFromServer = bidPayload;
}

- (NSString *)fetchFacebookBidderToken {
    return FBAdSettings.bidderToken;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = kFBAdSizeHeight250Rectangle;
    }
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    CGRect adframe = CGRectMake(0, 0, viewSize.width, adSize.size.height);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView =
            [[FBAdView alloc] initWithPlacementID:strongSelf.provider.data.key1
                                           adSize:adSize
                               rootViewController:[strongSelf.delegate rootViewControllerForPresentingModalView]];
        strongSelf.bannerView.delegate = strongSelf;
        strongSelf.bannerView.frame = adframe;

        [strongSelf.bannerView loadAdWithBidPayload:strongSelf.bidPayloadFromServer];
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
