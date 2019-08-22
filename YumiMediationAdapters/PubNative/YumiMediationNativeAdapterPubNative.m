//
//  YumiMediationNativeAdapterPubNative.m
//  Pods
//
//  Created by generator on 13/08/2019.
//
//

#import "YumiMediationNativeAdapterPubNative.h"
#import "YumiMediationNativeAdapterPubNativeConnector.h"
#import <HyBid/HyBid.h>
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationNativeAdapterPubNative () <YumiMediationNativeAdapter, HyBidNativeAdLoaderDelegate,
                                                   YumiMediationNativeAdapterConnectorDelegate, HyBidNativeAdDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;

@property (nonatomic) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) HyBidNativeAd *nativeAd;

@end

@implementation YumiMediationNativeAdapterPubNative
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeConfig;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDPubNative
                                                       requestType:YumiMediationSDKAdRequest];
}

- (void)dealloc {
    [self.nativeAd stopTracking];
}

#pragma mark - YumiMediationNativeAdapter
- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate {
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

- (void)requestAd:(NSUInteger)adCount {

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

    self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
    [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:self.provider.data.key2];
}
- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {

    HyBidNativeAd *pubNativeAd = nativeAd.data;

    // render class
    HyBidNativeAdRenderer *renderer = [[HyBidNativeAdRenderer alloc] init];

    UIView *adChoiceView = [[UIView alloc] init];
    [view addSubview:adChoiceView];

    CGFloat margin = 5; // left right margin
    [adChoiceView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
        make.height.width.mas_equalTo(15);
    }];
    self.nativeConfig.preferredAdChoicesPosition = YumiMediationAdViewPositionBottomLeftCorner;

    if (self.nativeConfig.preferredAdChoicesPosition == YumiMediationAdViewPositionTopRightCorner ||
        self.nativeConfig.preferredAdChoicesPosition == 0) {
        [adChoiceView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.top.equalTo(view).offset(0);
            make.right.equalTo(view).offset(-margin);
        }];
    }
    if (self.nativeConfig.preferredAdChoicesPosition == YumiMediationAdViewPositionTopLeftCorner) {
        [adChoiceView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.top.equalTo(view).offset(0);
            make.left.equalTo(view).offset(margin);
        }];
    }
    if (self.nativeConfig.preferredAdChoicesPosition == YumiMediationAdViewPositionBottomRightCorner) {
        [adChoiceView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.bottom.equalTo(view).offset(0);
            make.right.equalTo(view).offset(-margin);
        }];
    }
    if (self.nativeConfig.preferredAdChoicesPosition == YumiMediationAdViewPositionBottomLeftCorner) {
        [adChoiceView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.bottom.equalTo(view).offset(0);
            make.left.equalTo(view).offset(margin);
        }];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // update adChoiceView frame
        [view layoutIfNeeded];
        renderer.contentInfoView = adChoiceView;
        [pubNativeAd renderAd:renderer];
        [pubNativeAd startTrackingView:view withDelegate:weakSelf];
    });
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark :HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    self.nativeAd = nativeAd;

    YumiMediationNativeAdapterPubNativeConnector *connector =
        [[YumiMediationNativeAdapterPubNativeConnector alloc] init];
    [connector convertWithNativeData:self.nativeAd
                         withAdapter:self
                 disableImageLoading:self.nativeConfig.disableImageLoading
                   connectorDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

#pragma mark : YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel {
    [self.delegate adapter:self didReceiveAd:@[ nativeModel ]];
}

- (void)yumiMediationNativeAdFailed {
    [self.delegate adapter:self didFailToReceiveAd:@"pubNative convert fail"];
}

#pragma mark : HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    [self.delegate adapter:self didClick:nil];
}

@end
