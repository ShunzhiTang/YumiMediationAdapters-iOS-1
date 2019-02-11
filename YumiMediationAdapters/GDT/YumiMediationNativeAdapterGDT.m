//
//  YumiMediationNativeAdapterGDT.m
//  Pods
//
//  Created by 王泽永 on 2017/9/19.
//
//

#import "YumiMediationNativeAdapterGDT.h"
#import "GDTNativeAd.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import "YumiMediationNativeAdapterGDTConnector.h"

@interface YumiMediationNativeAdapterGDT () <YumiMediationNativeAdapter, GDTNativeAdDelegate,YumiMediationNativeAdapterConnectorDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) GDTNativeAd *nativeAd;

// origin gdt ads data
@property (nonatomic) NSArray<GDTNativeAdData *> *gdtNativeData;
// mapping data
@property (nonatomic) NSMutableArray<YumiMediationNativeModel *> *mappingData;

@end

@implementation YumiMediationNativeAdapterGDT
/// when conforming to a protocol, any property the protocol defines won't be automatically synthesized
@synthesize disableImageLoading;

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
- (void)loadNativeAdsWith:(NSUInteger)adCount{
    self.nativeAd =
    [[GDTNativeAd alloc] initWithAppId:self.provider.data.key1 ?: @"" placementId:self.provider.data.key2 ?: @""];
    self.nativeAd.delegate = self;
    self.nativeAd.controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.nativeAd loadAd:(int)adCount];
}

- (void)registerViewForNativeAdapterWith:(UIView *)view
                          viewController:(UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd {
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
    
    __weak typeof(self) weakSelf = self;
    [nativeAdDataArray enumerateObjectsUsingBlock:^(GDTNativeAdData *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        YumiMediationNativeAdapterGDTConnector *connector = [[YumiMediationNativeAdapterGDTConnector alloc] initWithYumiNativeConnector:obj withAdapter:weakSelf disableImageLoading:weakSelf.disableImageLoading connectorDelegate:weakSelf];
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

#pragma mark: -YumiMediationNativeAdapterConnectorDelegate
- (void)yumiMediationNativeAdSuccessful:(YumiMediationNativeModel *)nativeModel{
    
    [self.mappingData addObject:nativeModel];
    if (self.mappingData.count == self.gdtNativeData.count) {
        [self.delegate adapter:self didReceiveAd:[self.mappingData copy]];
    }
}

- (void)yumiMediationNativeAdFailed{
    NSError *error = [NSError errorWithDomain:@"" code:501 userInfo:@{@"error reason" : @"connector yumiAds data error"}];
    [self handleNativeError:error];
}

- (void)handleNativeError:(NSError *)error{
    
    [self clearNativeData];
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)clearNativeData{
    self.gdtNativeData = nil;
    [self.mappingData removeAllObjects];
}
#pragma mark: - getter method
- (NSMutableArray<YumiMediationNativeModel *> *)mappingData{
    if (!_mappingData) {
        
        _mappingData = [NSMutableArray arrayWithCapacity:1];
    }
    return _mappingData;
}

@end
