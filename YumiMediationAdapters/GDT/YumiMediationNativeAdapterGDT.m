//
//  YumiMediationNativeAdapterGDT.m
//  Pods
//
//  Created by 王泽永 on 2017/9/19.
//
//

#import "YumiMediationNativeAdapterGDT.h"
#import "GDTUnifiedNativeAd.h"
#import "GDTUnifiedNativeAdView.h"
#import "YumiMediationNativeAdapterGDTConnector.h"
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationNativeAdapterGDT () <YumiMediationNativeAdapter, GDTUnifiedNativeAdDelegate,
                                             YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) GDTUnifiedNativeAd *nativeAd;

// origin gdt ads data
@property (nonatomic) NSArray<GDTUnifiedNativeAdDataObject *> *gdtNativeData;
// mapping data
@property (nonatomic) NSMutableArray *mappingData;

@end

@implementation YumiMediationNativeAdapterGDT
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeConfig;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDT
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

#pragma mark - YumiMediationNativeAdapter
- (void)requestAd:(NSUInteger)adCount {
    // remove last data
    [self clearNativeData];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf loadNativeAdsWith:adCount];
    });
}
- (void)loadNativeAdsWith:(NSUInteger)adCount {
    self.nativeAd = [[GDTUnifiedNativeAd alloc] initWithAppId:self.provider.data.key1 ?: @""
                                                  placementId:self.provider.data.key2 ?: @""];
    self.nativeAd.delegate = self;

    [self.nativeAd loadAdWithAdCount:(int)adCount];
}

- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {
    NSMutableArray<UIView *> *clickables = [NSMutableArray array];
    GDTUnifiedNativeAdView *gdtView = [[GDTUnifiedNativeAdView alloc] initWithFrame:view.bounds];

    [view addSubview:gdtView];

    GDTLogoView *logoView = [[GDTLogoView alloc] init];

    [gdtView addSubview:logoView];
    CGFloat margin = 0;
    [logoView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
        make.width.mas_equalTo(kGDTLogoImageViewDefaultWidth);
        make.height.mas_equalTo(kGDTLogoImageViewDefaultHeight);
        make.bottom.equalTo(gdtView.mas_bottom).offset(-margin);
        make.right.equalTo(gdtView.mas_right).offset(-margin);
    }];

    GDTUnifiedNativeAdDataObject *gdtData = (GDTUnifiedNativeAdDataObject *)nativeAd.data;
    ((YumiMediationNativeAdapterGDTConnector *)nativeAd.extraAssets[adapterConnectorKey]).gdtNativeView = gdtView;

    [clickables addObject:gdtView];
    [clickables addObject:logoView];

    // media view
    if (clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset] && nativeAd.hasVideoContent) {
        UIView *mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset];
        GDTMediaView *mediaView = [[GDTMediaView alloc] initWithFrame:mediaSuperView.bounds];
        [mediaSuperView addSubview:mediaView];

        [gdtView registerDataObject:gdtData
                          mediaView:mediaView
                           logoView:logoView
                     viewController:[[YumiTool sharedTool] topMostController]
                     clickableViews:[clickables copy]];
        return;
    }

    [gdtView registerDataObject:gdtData
                       logoView:logoView
                 viewController:[[YumiTool sharedTool] topMostController]
                 clickableViews:[clickables copy]];
}

- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(nonnull UIView *)view {
}

- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark - GDTUnifiedNativeAdDelete
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *_Nullable)unifiedNativeAdDataObjects
                            error:(NSError *_Nullable)error {
    self.gdtNativeData = unifiedNativeAdDataObjects;

    __weak typeof(self) weakSelf = self;
    [unifiedNativeAdDataObjects
        enumerateObjectsUsingBlock:^(GDTUnifiedNativeAdDataObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [[[YumiMediationNativeAdapterGDTConnector alloc] init]
                convertWithNativeData:obj
                          withAdapter:weakSelf
                  disableImageLoading:weakSelf.nativeConfig.disableImageLoading
                    connectorDelegate:weakSelf];
        }];
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [self handleNativeError:error];
}

- (void)nativeAdWillPresentScreen {
    [self.delegate adapter:self didClick:nil];
}

- (void)nativeAdApplicationWillEnterBackground {
    [self.delegate adapter:self didClick:nil];
}

- (void)nativeAdClosed {
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

- (void)yumiMediationNativeAdDidClick:(YumiMediationNativeModel *)nativeModel {
    [self.delegate adapter:self didClick:nativeModel];
}

- (void)connectorDidFinishConvert {
    if (self.mappingData.count == self.gdtNativeData.count) {
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
            [NSError errorWithDomain:@"" code:501 userInfo:@{
                @"error reason" : @"connector yumiAds all data error"
            }];
        [self handleNativeError:error];
    }
}

- (void)handleNativeError:(NSError *)error {
    [self clearNativeData];
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)clearNativeData {
    self.gdtNativeData = nil;
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
