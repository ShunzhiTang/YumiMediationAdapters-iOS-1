//
//  YumiMediationNativeAdapterGDT.m
//  Pods
//
//  Created by 王泽永 on 2017/9/19.
//
//

#import "YumiMediationNativeAdapterGDT.h"
#import "GDTNativeAd.h"
#import "YumiMediationNativeAdapterGDTConnector.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiMediationNativeAdImageOptions.h>
#import <YumiMediationSDK/YumiMasonry.h>

@interface YumiMediationNativeAdapterGDT () <YumiMediationNativeAdapter, GDTNativeAdDelegate,
                                             YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) GDTNativeAd *nativeAd;

// origin gdt ads data
@property (nonatomic) NSArray<GDTNativeAdData *> *gdtNativeData;
// mapping data
@property (nonatomic) NSMutableArray<YumiMediationNativeModel *> *mappingData;
/// gdt Logo view
@property (nonatomic) UIImageView  *logoImgView;
@end

@implementation YumiMediationNativeAdapterGDT
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeOptions;

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
    self.nativeAd =
        [[GDTNativeAd alloc] initWithAppId:self.provider.data.key1 ?: @"" placementId:self.provider.data.key2 ?: @""];
    self.nativeAd.delegate = self;
    self.nativeAd.controller = [[YumiTool sharedTool] topMostController];
    [self.nativeAd loadAd:(int)adCount];
}

- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {
    if (self.logoImgView.superview == nil) {
        [view addSubview:self.logoImgView];
        CGFloat margin = 5;
        [self.logoImgView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.width.mas_equalTo(38);
            make.height.mas_equalTo(19);
            make.bottom.equalTo(view.mas_bottom).offset(-margin);
            make.right.equalTo(view.mas_right).offset(-margin);
        }];
    }
}

- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(nonnull UIView *)view {
    [self.nativeAd attachAd:nativeAd.data toView:view];
}

- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
    [self.nativeAd clickAd:nativeAd.data];
}

#pragma mark - GDTNativeAdDelegate
- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    self.gdtNativeData = nativeAdDataArray;

    __block BOOL disableImageLoading;
    [self.nativeOptions enumerateObjectsUsingBlock:^(YumiMediationNativeOptions * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[YumiMediationNativeAdImageOptions class]]) {
            disableImageLoading = ((YumiMediationNativeAdImageOptions *)obj).disableImageLoading;
            *stop = YES;
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    [nativeAdDataArray
        enumerateObjectsUsingBlock:^(GDTNativeAdData *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [[[YumiMediationNativeAdapterGDTConnector alloc] init] convertWithNativeData:obj
                                                                             withAdapter:weakSelf
                                                                     disableImageLoading:disableImageLoading
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
    if (self.mappingData.count == self.gdtNativeData.count) {
        [self.delegate adapter:self didReceiveAd:[self.mappingData copy]];
    }
}

- (void)yumiMediationNativeAdFailed {
    NSError *error =
        [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : @"connector yumiAds data error"}];
    [self handleNativeError:error];
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
- (NSMutableArray<YumiMediationNativeModel *> *)mappingData {
    if (!_mappingData) {
        _mappingData = [NSMutableArray arrayWithCapacity:1];
    }
    return _mappingData;
}
- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        NSBundle *YumiAdsSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiAdsSDK"];;
        NSString *strPath = [YumiAdsSDK pathForResource:@"yumiad_flag_gdt@2x" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:strPath];
        _logoImgView.image = image;
    }
    return _logoImgView;
}
@end
