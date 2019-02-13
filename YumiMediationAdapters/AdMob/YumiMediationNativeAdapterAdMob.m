//
//  YumiMediationNativeAdapterAdMob.m
//  Pods
//
//  Created by generator on 11/02/2019.
//
//

#import "YumiMediationNativeAdapterAdMob.h"
#import "YumiMediationNativeAdapterAdMobConnector.h"
#import <GoogleMobileAds/GADNativeAdViewAdOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationNativeAdapterAdMob () <YumiMediationNativeAdapter, GADAdLoaderDelegate,
                                               GADUnifiedNativeAdLoaderDelegate,
                                               YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) GADAdLoader *adLoader;
// origin gad ads data
@property (nonatomic) NSMutableArray<GADUnifiedNativeAd *> *gadNativeData;
// mapping data
@property (nonatomic) NSMutableArray<YumiMediationNativeModel *> *mappingData;

@end

@implementation YumiMediationNativeAdapterAdMob
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize disableImageLoading;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAdMob
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

    [self clearNativeData];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

        // options
        GADNativeAdViewAdOptions *adViewoption = [[GADNativeAdViewAdOptions alloc] init];
        adViewoption.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;

        GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
        multipleAdsOptions.numberOfAds = adCount;

        GADNativeAdImageAdLoaderOptions *imageOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
        imageOptions.disableImageLoading = weakSelf.disableImageLoading;
        // adType
        NSMutableArray *adTypes = [[NSMutableArray alloc] init];
        [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];

        weakSelf.adLoader = [[GADAdLoader alloc] initWithAdUnitID:weakSelf.provider.data.key1
                                               rootViewController:[[YumiTool sharedTool] topMostController]
                                                          adTypes:adTypes
                                                          options:@[ adViewoption, multipleAdsOptions, imageOptions ]];

        GADRequest *request = [GADRequest request];

        weakSelf.adLoader.delegate = weakSelf;
        [weakSelf.adLoader loadRequest:request];
    });
}
- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {
    GADUnifiedNativeAd *gadNativeAd = (GADUnifiedNativeAd *)nativeAd.data;

    GADUnifiedNativeAdView *gadView = [[GADUnifiedNativeAdView alloc] initWithFrame:view.bounds];
    gadView.nativeAd = gadNativeAd;

    if (clickableAssetViews[YumiMediationUnifiedNativeTitleAsset]) {
        gadView.headlineView = clickableAssetViews[YumiMediationUnifiedNativeTitleAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeDescAsset]) {
        gadView.bodyView = clickableAssetViews[YumiMediationUnifiedNativeDescAsset];
    }

    if (clickableAssetViews[YumiMediationUnifiedNativeIconAsset]) {
        gadView.iconView = clickableAssetViews[YumiMediationUnifiedNativeIconAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset]) {
        gadView.imageView = clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset]) {
        gadView.callToActionView = clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAppPriceAsset]) {
        gadView.priceView = clickableAssetViews[YumiMediationUnifiedNativeAppPriceAsset];
    }

    if (clickableAssetViews[YumiMediationUnifiedNativeStoreAsset]) {
        gadView.storeView = clickableAssetViews[YumiMediationUnifiedNativeStoreAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAppRatingAsset]) {
        gadView.starRatingView = clickableAssetViews[YumiMediationUnifiedNativeAppRatingAsset];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAdvertiserAsset]) {
        gadView.advertiserView = clickableAssetViews[YumiMediationUnifiedNativeAdvertiserAsset];
    }

    [view addSubview:gadView];
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark : -GADAdLoaderDelegate
- (void)adLoader:(nonnull GADAdLoader *)adLoader didFailToReceiveAdWithError:(nonnull GADRequestError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}
/// Called after adLoader has finished loading.
- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
    __weak typeof(self) weakSelf = self;
    [self.gadNativeData
        enumerateObjectsUsingBlock:^(GADUnifiedNativeAd *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [[[YumiMediationNativeAdapterAdMobConnector alloc] init] convertWithNativeData:obj
                                                                               withAdapter:weakSelf
                                                                         connectorDelegate:weakSelf];
        }];
}
#pragma mark : -GADUnifiedNativeAdLoaderDelegate
/// Called when a unified native ad is received.
- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(nonnull GADUnifiedNativeAd *)nativeAd {
    [self.gadNativeData addObject:nativeAd];
}

#pragma mark : YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel {
    [self.mappingData addObject:nativeModel];
    if (self.mappingData.count == self.gadNativeData.count) {
        [self.delegate adapter:self didReceiveAd:[self.mappingData copy]];
    }
}

- (void)yumiMediationNativeAdFailed {
    NSError *error =
        [NSError errorWithDomain:@"" code:501 userInfo:@{
            @"error reason" : @"connector yumiAds data error"
        }];
    [self handleNativeError:error];
}

- (void)yumiMediationNativeAdDidClick:(YumiMediationNativeModel *)nativeModel {
    [self.delegate adapter:self didClick:nil];
}

- (void)handleNativeError:(NSError *)error {
    [self clearNativeData];
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)clearNativeData {
    [self.gadNativeData removeAllObjects];
    [self.mappingData removeAllObjects];
}

#pragma mark : - getter method
- (NSMutableArray<YumiMediationNativeModel *> *)mappingData {
    if (!_mappingData) {
        _mappingData = [NSMutableArray arrayWithCapacity:1];
    }
    return _mappingData;
}
- (NSMutableArray<GADUnifiedNativeAd *> *)gadNativeData {
    if (!_gadNativeData) {
        _gadNativeData = [NSMutableArray arrayWithCapacity:1];
    }
    return _gadNativeData;
}

@end
