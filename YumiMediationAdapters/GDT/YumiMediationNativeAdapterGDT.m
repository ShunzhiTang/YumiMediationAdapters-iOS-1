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

@interface YumiMediationNativeAdapterGDT () <YumiMediationNativeAdapter, GDTNativeAdDelegate>

@property (nonatomic, weak) id<YumiMediationNativeAdapterDelegate> delegate;
@property (nonatomic) YumiMediationNativeProvider *provider;
@property (nonatomic) GDTNativeAd *nativeAd;

@end

@implementation YumiMediationNativeAdapterGDT

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
    NSArray<YumiMediationNativeModel *> *mediationArray = [self transitToMediationModel:nativeAdDataArray];
    [self.delegate adapter:self didReceiveAd:mediationArray];
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:error.localizedDescription];
}

- (void)nativeAdWillPresentScreen {
    [self.delegate adapter:self didClick:nil];
}

- (void)nativeAdApplicationWillEnterBackground {
    [self.delegate adapter:self didClick:nil];
}

- (void)nativeAdClosed {
}

#pragma mark - transitModel
- (NSArray<YumiMediationNativeModel *> *)transitToMediationModel:(NSArray *)thirdpartyData {
    YumiMediationNativeModel *mediationModel = [YumiMediationNativeModel new];
    NSMutableArray<YumiMediationNativeModel *> *mediationArray =
        [NSMutableArray arrayWithCapacity:thirdpartyData.count];

    [thirdpartyData enumerateObjectsUsingBlock:^(GDTNativeAdData *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [mediationModel setValue:obj forKey:@"data"];

        if (obj.properties[GDTNativeAdDataKeyTitle] &&
            [obj.properties[GDTNativeAdDataKeyTitle] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyTitle] forKey:@"title"];
        }
        if (obj.properties[GDTNativeAdDataKeyDesc] &&
            [obj.properties[GDTNativeAdDataKeyDesc] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyDesc] forKey:@"desc"];
        }
        if (obj.properties[GDTNativeAdDataKeyImgUrl] &&
            [obj.properties[GDTNativeAdDataKeyImgUrl] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyImgUrl] forKey:@"coverImageURL"];
        }
        if (obj.properties[GDTNativeAdDataKeyIconUrl] &&
            [obj.properties[GDTNativeAdDataKeyIconUrl] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyIconUrl] forKey:@"iconURL"];
        }
        if (obj.properties[GDTNativeAdDataKeyAppRating] &&
            [obj.properties[GDTNativeAdDataKeyAppRating] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyAppRating] forKey:@"appRating"];
        }
        if (obj.properties[GDTNativeAdDataKeyAppPrice] &&
            [obj.properties[GDTNativeAdDataKeyAppPrice] isKindOfClass:[NSString class]]) {
            [mediationModel setValue:obj.properties[GDTNativeAdDataKeyAppPrice] forKey:@"appPrice"];
        }
        [mediationArray addObject:mediationModel];
    }];
    return mediationArray;
}

@end
