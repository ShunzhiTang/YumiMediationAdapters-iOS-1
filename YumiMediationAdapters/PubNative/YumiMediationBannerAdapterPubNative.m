//
//  YumiMediationBannerAdapterPubNative.m
//  Pods
//
//  Created by generator on 13/08/2019.
//
//

#import "YumiMediationBannerAdapterPubNative.h"
#import <HyBid/HyBid.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterPubNative () <YumiMediationBannerAdapter, HyBidAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@property (nonatomic) HyBidBannerAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterPubNative

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDPubNative
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        // Call this to let PubNative know the user has granted consent
        [[HyBidUserDataManager sharedInstance] grantConsent];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        // Call this to let PubNative know the user has revoked consent
        [[HyBidUserDataManager sharedInstance] denyConsent];
    }
    // init sdk
    [HyBid initWithAppToken:self.provider.data.key1
                 completion:^(BOOL success) {
                     if (success) {
                         /// ...
                     }
                 }];

    return self;
}

- (NSString *)networkVersion {
    return @"1.3.7";
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {

    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        // Call this to let PubNative know the user has granted consent
        [[HyBidUserDataManager sharedInstance] grantConsent];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        // Call this to let PubNative know the user has revoked consent
        [[HyBidUserDataManager sharedInstance] denyConsent];
    }

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);

    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape ||
        self.bannerSize == kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"pubNative not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape or kYumiMediationAdViewBanner300x250"];
        return;
    }

    CGRect adFrame = CGRectMake(0, 0, adSize.width, adSize.height);
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.bannerView = [[HyBidBannerAdView alloc] initWithFrame:adFrame];
        [weakSelf.bannerView loadWithZoneID:weakSelf.provider.data.key2 andWithDelegate:weakSelf];
    });
}

#pragma mark : - HyBidAdViewDelegate
- (void)adViewDidLoad:(HyBidAdView *)adView {
    [self.delegate adapter:self didReceiveAd:self.bannerView];
}
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
}
- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    [self.delegate adapter:self didClick:self.bannerView];
}

@end
