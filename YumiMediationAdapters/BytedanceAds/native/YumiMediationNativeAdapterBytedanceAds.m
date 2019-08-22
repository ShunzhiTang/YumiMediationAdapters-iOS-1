//
//  YumiMediationNativeAdapterBytedanceAds.m
//  Pods
//
//  Created by generator on 23/05/2019.
//
//

#import "YumiMediationNativeAdapterBytedanceAds.h"
#import "YumiMediationNativeAdapterBytedanceAdsConnector.h"
#import <BUAdSDK/BUAdSDK.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationNativeAdapterBytedanceAds () <YumiMediationNativeAdapter, BUNativeAdsManagerDelegate,
                                                      YumiMediationNativeAdapterConnectorDelegate, BUNativeAdDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic, strong) BUNativeAdsManager *buNativeManager;
@property (nonatomic) NSArray<BUNativeAd *> *buNativeAdDataArray;
// mapping data
@property (nonatomic) NSMutableArray *mappingData;

@end

@implementation YumiMediationNativeAdapterBytedanceAds
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeConfig;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBytedanceAds
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationNativeAdapter
- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [BUAdSDKManager setAppID:provider.data.key1];

    return self;
}

- (NSString *)networkVersion {
    return @"2.0.1.1";
}

- (void)requestAd:(NSUInteger)adCount {

    [self clearNativeData];

    self.buNativeManager = [[BUNativeAdsManager alloc] init];
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = self.provider.data.key2;
    slot1.AdType = BUAdSlotAdTypeFeed;
    slot1.position = BUAdSlotPositionTop;
    slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
    slot1.isSupportDeepLink = YES;

    self.buNativeManager.adslot = slot1;
    self.buNativeManager.delegate = self;

    [self.buNativeManager loadAdDataWithCount:adCount];
}

- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {

    BUNativeAd *buNativeData = nativeAd.data;

    [buNativeData unregisterView];

    NSMutableArray *clickViews = [NSMutableArray array];

    if (clickableAssetViews[YumiMediationUnifiedNativeTitleAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeTitleAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeDescAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeDescAsset]];
    }

    if (clickableAssetViews[YumiMediationUnifiedNativeIconAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeIconAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAppPriceAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeAppPriceAsset]];
    }

    if (clickableAssetViews[YumiMediationUnifiedNativeStoreAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeStoreAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAppRatingAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeAppRatingAsset]];
    }
    if (clickableAssetViews[YumiMediationUnifiedNativeAdvertiserAsset]) {
        [clickViews addObject:clickableAssetViews[YumiMediationUnifiedNativeAdvertiserAsset]];
    }

    if (nativeAd.hasVideoContent) {
        UIView *mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset];
        // have media view
        if (clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset]) {
            mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset];
        }
        BUNativeAdRelatedView *nativeAdRelatedView = [[BUNativeAdRelatedView alloc] init];
        nativeAdRelatedView.videoAdView.frame = mediaSuperView.bounds;

        [mediaSuperView addSubview:nativeAdRelatedView.videoAdView];
        [nativeAdRelatedView refreshData:buNativeData];

        // set BUNativeAdRelatedView view
        ((YumiMediationNativeAdapterBytedanceAdsConnector *)nativeAd.extraAssets[adapterConnectorKey])
            .nativeAdRelatedView = nativeAdRelatedView;
    }

    [buNativeData registerContainer:view withClickableViews:[clickViews copy]];

    buNativeData.delegate = self;
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark : BUNativeAdDelegate
- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.delegate adapter:self didClick:nil];
}

#pragma mark : BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager
                            nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    self.buNativeAdDataArray = nativeAdDataArray;
    __weak typeof(self) weakSelf = self;
    [nativeAdDataArray enumerateObjectsUsingBlock:^(BUNativeAd *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [[[YumiMediationNativeAdapterBytedanceAdsConnector alloc] init]
            convertWithNativeData:obj
                      withAdapter:weakSelf
              disableImageLoading:weakSelf.nativeConfig.disableImageLoading
                connectorDelegate:weakSelf];
    }];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self handleNativeError:error];
}

#pragma mark : -YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel {
    [self.mappingData addObject:nativeModel];

    [self connectorDidFinishConvert];
}

- (void)yumiMediationNativeAdFailed {

    [self.mappingData addObject:@"error"];
    [self connectorDidFinishConvert];
}

- (void)connectorDidFinishConvert {
    if (self.mappingData.count == self.buNativeAdDataArray.count) {
        NSMutableArray<YumiMediationNativeModel *> *results = [NSMutableArray arrayWithCapacity:1];
        [self.mappingData enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[YumiMediationNativeModel class]]) {
                [results addObject:obj];
            }
        }];

        if (results.count > 0) {
            [self.delegate adapter:self didReceiveAd:[results copy]];
            return;
        }
        NSError *error =
            [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : @"connector yumiAds all data error"}];
        [self handleNativeError:error];
    }
}

- (void)handleNativeError:(NSError *)error {
    [self clearNativeData];
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)clearNativeData {
    self.buNativeAdDataArray = nil;
    [self.mappingData removeAllObjects];
}

#pragma mark : - getter method
- (NSMutableArray *)mappingData {
    if (!_mappingData) {
        _mappingData = [NSMutableArray arrayWithCapacity:1];
    }
    return _mappingData;
}

@end
