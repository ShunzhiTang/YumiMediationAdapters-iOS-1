//
//  YumiMediationNativeAdapterGDT.m
//  Pods
//
//  Created by 王泽永 on 2017/9/19.
//
//

#import "YumiMediationNativeAdapterGDT.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "GDTUnifiedNativeAd.h"
#import "GDTUnifiedNativeAdView.h"
#import "YumiMediationNativeAdapterGDTConnector.h"
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

// 0: template
// 1: reder
// Default is 0
static NSString *const kYumiProviderExtraGDTRenderModel = @"GDTRenderModel";

@interface YumiMediationNativeAdapterGDT () <YumiMediationNativeAdapter, GDTUnifiedNativeAdDelegate,
                                             YumiMediationNativeAdapterConnectorDelegate, GDTNativeExpressAdDelegete>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;

/// native ad
@property (nonatomic) GDTUnifiedNativeAd *nativeAd;
// native  express ad
@property (nonatomic) GDTNativeExpressAd *nativeExpressAd;

// origin gdt ads data
@property (nonatomic) NSArray *gdtNativeData;
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

- (NSString *)networkVersion {
    return @"4.10.19";
}

- (void)loadNativeAdsWith:(NSUInteger)adCount {

    // 0： 模版形式 ，1：自渲染 ，默认是0
    int renderMode = 0;

    if (![self.provider.data.extra[kYumiProviderExtraGDTRenderModel] isKindOfClass:[NSNumber class]]) {
        renderMode = 0;
    } else {
        renderMode = [self.provider.data.extra[kYumiProviderExtraGDTRenderModel] intValue];
    }

    // need to request expressAd
    if (renderMode == 0) {
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:self.provider.data.key1 ?: @""
                                                             placementId:self.provider.data.key2 ?: @""
                                                                  adSize:self.nativeConfig.expressAdSize];

        self.nativeExpressAd.delegate = self;
        self.nativeExpressAd.videoMuted = NO;

        [self.nativeExpressAd loadAd:adCount];
        return;
    }
    // native ad
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

    if (nativeAd.isExpressAdView) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)nativeAd.expressAdView;

        expressView.controller = viewController;

        [expressView render];

        return;
    }

    NSMutableArray<UIView *> *clickables = [NSMutableArray array];
    GDTUnifiedNativeAdView *gdtView = [[GDTUnifiedNativeAdView alloc] initWithFrame:view.bounds];
    
    gdtView.viewController = viewController;
    
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

    //注册可点击的callToAction视图的方法
    if (!clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset]) {
        [gdtView registerClickableCallToActionView:clickableAssetViews[YumiMediationUnifiedNativeCallToActionAsset]];
    }
    
    // media view
    if (nativeAd.hasVideoContent) {
        UIView *mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset];
        // have media view
        if (clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset]) {
            mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset];
        }

        GDTMediaView *mediaView = [[GDTMediaView alloc] initWithFrame:mediaSuperView.bounds];
        [mediaView muteEnable:YES];
        
        [mediaSuperView addSubview:mediaView];

        [clickables addObject:mediaView];
        
        [gdtView registerDataObject:gdtData clickableViews:[clickables copy]];
        return;
    }

    [gdtView registerDataObject:gdtData clickableViews:[clickables copy]];
}

- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(nonnull UIView *)view {
}

- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark : - private method
- (YumiMediationNativeModel *)getNativeModelWith:(GDTNativeExpressAdView *)nativeExpressAdView {
    __block YumiMediationNativeModel *nativeModel = nil;
    [self.mappingData enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[YumiMediationNativeModel class]]) {
            if ([((YumiMediationNativeModel *)obj).expressAdView isEqual:nativeExpressAdView]) {
                nativeModel = obj;
                *stop = YES;
            }
        }
    }];

    return nativeModel;
}

#pragma mark - GDTUnifiedNativeAdDelete
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *_Nullable)unifiedNativeAdDataObjects
                            error:(NSError *_Nullable)error {
    if (unifiedNativeAdDataObjects.count == 0 && error) {
        [self handleNativeError:error];
        return;
    }
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

#pragma mark : GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd
                               views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {

    self.gdtNativeData = views;

    __weak typeof(self) weakSelf = self;
    [views enumerateObjectsUsingBlock:^(__kindof GDTNativeExpressAdView *_Nonnull obj, NSUInteger idx,
                                        BOOL *_Nonnull stop) {
        [[[YumiMediationNativeAdapterGDTConnector alloc] init]
            convertWithNativeData:obj
                      withAdapter:weakSelf
              disableImageLoading:weakSelf.nativeConfig.disableImageLoading
                connectorDelegate:weakSelf];
    }];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self handleNativeError:error];
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {

    [self.delegate adapter:self nativeExpressAdViewRenderSuccess:[self getNativeModelWith:nativeExpressAdView]];
}

- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {

    [self.delegate adapter:self
           nativeExpressAd:[self getNativeModelWith:nativeExpressAdView]
             didRenderFail:@"gdt express ad view render fail"];
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self nativeExpressAdDidClose:[self getNativeModelWith:nativeExpressAdView]];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.delegate adapter:self didClick:nil];
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
            [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : @"connector yumiAds all data error"}];
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
