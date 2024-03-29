//
//  YumiMediationNativeAdapterBaidu.m
//  Pods
//
//  Created by generator on 14/02/2019.
//
//

#import "YumiMediationNativeAdapterBaidu.h"
#import "YumiMediationNativeAdapterBaiduConnector.h"
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdDelegate.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeVideoView.h>
#import <YumiMediationSDK/YumiMasonry.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationNativeAdapterBaidu () <YumiMediationNativeAdapter, BaiduMobAdNativeAdDelegate,
                                               YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) BaiduMobAdNative *native;

// origin baidu ads data
@property (nonatomic) NSArray<BaiduMobAdNativeAdObject *> *bdNativeData;
// mapping data
@property (nonatomic) NSMutableArray *mappingData;

@end

@implementation YumiMediationNativeAdapterBaidu
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize nativeConfig;

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerNativeAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBaidu
                                                       requestType:YumiMediationSDKAdRequest];
}

- (void)dealloc {
    [self clearNativeData];
}

#pragma mark - YumiMediationNativeAdapter
- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (NSString *)networkVersion {
    return @"4.6.7";
}

- (void)requestAd:(NSUInteger)adCount {

    [self clearNativeData];

    self.native = [[BaiduMobAdNative alloc] init];
    self.native.publisherId = self.provider.data.key1;
    self.native.adId = self.provider.data.key2;
    self.native.delegate = self;
    // request native ads
    __weak typeof(self) wealSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
         [wealSelf.native requestNativeAds];
    });
   
}
- (void)registerViewForNativeAdapterWith:(UIView *)view
                     clickableAssetViews:
                         (NSDictionary<YumiMediationUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
                      withViewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {

    BaiduMobAdNativeAdObject *bdNativeAd = (BaiduMobAdNativeAdObject *)nativeAd.data;

    BaiduMobAdNativeAdView *bdView = nil;
    if (bdNativeAd.materialType == NORMAL) {
        bdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:view.bounds
                                                     brandName:nil
                                                         title:nil
                                                          text:nil
                                                          icon:nil
                                                     mainImage:nil];
    } else if (bdNativeAd.materialType == VIDEO) {

        BaiduMobAdNativeVideoView *videoView;

        UIView *mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeCoverImageAsset];
        // have media view
        if (clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset]) {
            mediaSuperView = clickableAssetViews[YumiMediationUnifiedNativeMediaViewAsset];
        }

        videoView = [[BaiduMobAdNativeVideoView alloc] initWithFrame:mediaSuperView.frame andObject:bdNativeAd];

        bdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:view.bounds
                                                     brandName:nil
                                                         title:nil
                                                          text:nil
                                                          icon:nil
                                                     mainImage:nil
                                                     videoView:videoView];
        // set baidu video view
        ((YumiMediationNativeAdapterBaiduConnector *)nativeAd.extraAssets[adapterConnectorKey]).videoView = videoView;
    }

    if (bdView) {
        [view addSubview:bdView];

        // add baidu logo
        UIImageView *baiduLogoView = [[UIImageView alloc] init];
        bdView.baiduLogoImageView = baiduLogoView;
        [bdView addSubview:baiduLogoView];

        CGFloat margin = 0;
        [baiduLogoView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
            make.height.width.mas_equalTo(18);
            make.bottom.equalTo(bdView.mas_bottom).offset(-margin);
            make.right.equalTo(bdView.mas_right).offset(-margin);
        }];

        [bdView loadAndDisplayNativeAdWithObject:bdNativeAd
                                      completion:^(NSArray *errors){

                                      }];
    }
}

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view {
    BaiduMobAdNativeAdObject *bdNativeAd = (BaiduMobAdNativeAdObject *)nativeAd.data;
    [bdNativeAd trackImpression:view];
}
- (void)clickAd:(YumiMediationNativeModel *)nativeAd {
}

#pragma mark : BaiduMobAdNativeAdDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    self.bdNativeData = nativeAds;

    __weak typeof(self) weakSelf = self;
    [nativeAds
        enumerateObjectsUsingBlock:^(BaiduMobAdNativeAdObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [[[YumiMediationNativeAdapterBaiduConnector alloc] init]
                convertWithNativeData:obj
                          withAdapter:weakSelf
                  disableImageLoading:weakSelf.nativeConfig.disableImageLoading
                    connectorDelegate:weakSelf];
        }];
}

- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason nativeAd:(BaiduMobAdNative *)nativeAd {
    NSString *errorReason = [NSString stringWithFormat:@"BaiduMobFailReason is %u", reason];
    NSError *error = [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : errorReason}];
    [self handleNativeError:error];
}

- (void)nativeAdClicked:(UIView *)nativeAdView {
    [self.delegate adapter:self didClick:nil];
}

- (void)didDismissLandingPage:(UIView *)nativeAdView {
}

#pragma mark : YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel {
    [self.mappingData addObject:nativeModel];

    [self connectorDidFinishConvert];
}

- (void)yumiMediationNativeAdFailed {

    [self.mappingData addObject:@"error"];
    [self connectorDidFinishConvert];
}

- (void)connectorDidFinishConvert {
    if (self.mappingData.count == self.bdNativeData.count) {
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
    if (self.native) {
        self.native.delegate = nil;
        self.native = nil;
    }
    self.bdNativeData = nil;
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
