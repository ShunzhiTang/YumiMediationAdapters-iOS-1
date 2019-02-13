//
//  YumiMediationNativeAdapterFacebook.m
//  Pods
//
//  Created by generator on 13/02/2019.
//
//

#import "YumiMediationNativeAdapterFacebook.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationNativeAdapterFacebook () <YumiMediationNativeAdapter>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;

@end

@implementation YumiMediationNativeAdapterFacebook
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize disableImageLoading;

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

    // TODO: setup code

    return self;
}

- (void)requestAd:(NSUInteger)adCount {
}
- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

// TODO: implement third party sdk delegate and delegate to mediation sdk

@end
