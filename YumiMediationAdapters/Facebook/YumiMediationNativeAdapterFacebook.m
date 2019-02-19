//
//  YumiMediationNativeAdapterFacebook.m
//  Pods
//
//  Created by generator on 13/02/2019.
//
//

#import "YumiMediationNativeAdapterFacebook.h"
#import "YumiMediationNativeAdapterFacebookConnector.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationNativeAdImageOptions.h>
#import <YumiMediationSDK/YumiMediationNativeAdViewOptions.h>

@interface YumiMediationNativeAdapterFacebook () <YumiMediationNativeAdapter, FBNativeAdDelegate,
                                                  YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;

@property (nonatomic) FBNativeAd *fbNativeAd;
@property (nonatomic) FBMediaView *mediaView;
@property (nonatomic) FBAdIconView *iconView;

@end

@implementation YumiMediationNativeAdapterFacebook
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeOptions;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDFacebook
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationNativeAdapter
- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (void)requestAd:(NSUInteger)adCount {

    self.fbNativeAd = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:weakSelf.provider.data.key1];
        nativeAd.delegate = weakSelf;
        [nativeAd loadAd];
    });
}
- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {

    if (clickableAssetViews[YumiMediationUnifiedNativeIconAsset]) {
        UIView *icon = clickableAssetViews[YumiMediationUnifiedNativeIconAsset];
        self.iconView = [[FBAdIconView alloc] initWithFrame:icon.bounds];
        [icon addSubview:self.iconView];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset]) {
        UIView *mediaView = clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset];
        self.mediaView = [[FBMediaView alloc] initWithFrame:mediaView.bounds];
        [mediaView addSubview:self.mediaView];
    }
    // AdChoices icon
    __block YumiMediationNativeAdViewOptions *yumiAdViewOption = nil;
    [self.nativeOptions enumerateObjectsUsingBlock:^(YumiMediationNativeOptions * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[YumiMediationNativeAdViewOptions class]]) {
            yumiAdViewOption = (YumiMediationNativeAdViewOptions *)obj;
            *stop = YES;
        }
    }];
    
    FBAdChoicesView *adChoicesView = [[FBAdChoicesView alloc] initWithNativeAd:self.fbNativeAd];
    if (yumiAdViewOption.preferredAdChoicesPosition == YumiMediationAdViewPositionTopRightCorner || yumiAdViewOption.preferredAdChoicesPosition == 0) {
       adChoicesView.corner = UIRectCornerTopRight;
    }
    if (yumiAdViewOption.preferredAdChoicesPosition == YumiMediationAdViewPositionTopLeftCorner) {
        adChoicesView.corner = UIRectCornerTopLeft;
    }
    if (yumiAdViewOption.preferredAdChoicesPosition == YumiMediationAdViewPositionBottomRightCorner) {
        adChoicesView.corner = UIRectCornerBottomRight;
    }
    if (yumiAdViewOption.preferredAdChoicesPosition == YumiMediationAdViewPositionBottomLeftCorner) {
       adChoicesView.corner = UIRectCornerBottomLeft;
    }
    
    [view addSubview:adChoicesView];
    [adChoicesView updateFrameFromSuperview];

    [self.fbNativeAd registerViewForInteraction:view
                                      mediaView:self.mediaView
                                       iconView:self.iconView
                                 viewController:viewController];
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark : FBNativeAdDelegate
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {

    if (self.fbNativeAd) {
        [self.fbNativeAd unregisterView];
    }

    self.fbNativeAd = nativeAd;
    
    __block BOOL disableImageLoading;
    [self.nativeOptions enumerateObjectsUsingBlock:^(YumiMediationNativeOptions * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[YumiMediationNativeAdImageOptions class]]) {
            disableImageLoading = ((YumiMediationNativeAdImageOptions *)obj).disableImageLoading;
            *stop = YES;
        }
    }];
    
    [[[YumiMediationNativeAdapterFacebookConnector alloc] init] convertWithNativeData:nativeAd
                                                                          withAdapter:self
                                                                  disableImageLoading:disableImageLoading
                                                                    connectorDelegate:self];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self handleNativeError:error];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {

    [self.delegate adapter:self didClick:nil];
}

#pragma mark : YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel {
    if (nativeModel) {
        [self.delegate adapter:self didReceiveAd:@[ nativeModel ]];
    }
}

- (void)yumiMediationNativeAdFailed {
    NSError *error =
        [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : @"connector yumiAds data error"}];
    [self handleNativeError:error];
}

- (void)handleNativeError:(NSError *)error {

    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}
@end
