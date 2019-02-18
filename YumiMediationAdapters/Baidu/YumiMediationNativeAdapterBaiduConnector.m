//
//  YumiMediationNativeAdapterBaiduConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/14.
//

#import "YumiMediationNativeAdapterBaiduConnector.h"

@interface YumiMediationNativeAdapterBaiduConnector ()

@property (nonatomic) BaiduMobAdNativeAdObject *nativeObject;
@property (nonatomic) YumiMediationNativeAdImage *icon;
@property (nonatomic) YumiMediationNativeAdImage *coverImage;
@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;

@end

@implementation YumiMediationNativeAdapterBaiduConnector

- (void)convertWithNativeData:(nullable BaiduMobAdNativeAdObject *)nativeObject
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {

    self.adapter = adapter;
    self.nativeObject = nativeObject;
    self.connectorDelegate = connectorDelegate;

    NSString *iconUrl = nativeObject.iconImageURLString;
    NSString *coverImageUrl = nativeObject.mainImageURLString;
    [self downloadIcon:iconUrl
                 coverImage:coverImageUrl
        disableImageLoading:disableImageLoading
                  completed:^(BOOL isSuccessed) {
                      [self notifyCompletionWithResult:isSuccessed];
                  }];
}
#pragma mark : handle download images
- (void)downloadIcon:(NSString *)iconUrl
             coverImage:(NSString *)coverImageUrl
    disableImageLoading:(BOOL)disableImageLoading
              completed:(void (^)(BOOL isSuccessed))completed {

    NSURL *iconImgUrl = [NSURL URLWithString:iconUrl];
    NSURL *coverUrl = [NSURL URLWithString:coverImageUrl];

    self.icon = [[YumiMediationNativeAdImage alloc] initWithURL:iconImgUrl];
    self.coverImage = [[YumiMediationNativeAdImage alloc] initWithURL:coverUrl];

    if (disableImageLoading) {

        completed(YES);
        return;
    }

    __weak typeof(self) weakSelf = self;
    NSMutableArray *imageTemps = [NSMutableArray arrayWithCapacity:1];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_enter(group);
    [self.icon loadImageAsyncWithBlock:^(UIImage *_Nullable image) {
        if (image) {
            [imageTemps addObject:@"1"];
            [weakSelf.icon setValue:@(image.size.width / image.size.height) forKey:@"ratios"];
        }

        dispatch_group_leave(group);
    }];
    dispatch_group_enter(group);
    [self.coverImage loadImageAsyncWithBlock:^(UIImage *_Nullable image) {
        if (image) {
            [imageTemps addObject:@"1"];
            [weakSelf.coverImage setValue:@(image.size.width / image.size.height) forKey:@"ratios"];
        }
        dispatch_group_leave(group);
    }];
    // 异步是否执行完
    dispatch_group_notify(group, queue, ^{
        if (imageTemps.count != 2) {
            completed(NO);
            return;
        }
        completed(YES);
    });
}

#pragma mark - Completion

- (void)notifyCompletionWithResult:(BOOL)isSuccessed {
    if (isSuccessed) {
        [self notifyMediatedNativeAdSuccessful];
    } else {
        [self notifyMediatedNativeAdFailed];
    }
}

- (void)notifyMediatedNativeAdSuccessful {
    YumiMediationNativeModel *nativeModel = [[YumiMediationNativeModel alloc] init];
    [nativeModel setValue:self forKey:@"unifiedNativeAd"];

    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdSuccessful:)]) {
        [self.connectorDelegate yumiMediationNativeAdSuccessful:nativeModel];
    }
}

- (void)notifyMediatedNativeAdFailed {
    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdFailed)]) {
        [self.connectorDelegate yumiMediationNativeAdFailed];
    }
}

#pragma mark : YumiMediationUnifiedNativeAd
- (NSString *)title {
    return self.nativeObject.title;
}
- (NSString *)desc {
    return self.nativeObject.text;
}

- (NSString *)callToAction {
    return nil;
}
- (NSString *)appPrice {
    return nil;
}
- (NSString *)advertiser {
    return nil;
}
- (NSString *)store {
    return nil;
}
- (NSString *)appRating {
    return nil;
    ;
}
- (NSString *)other {
    return nil;
}

- (id)data {
    return self.nativeObject;
}

- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}

- (NSDictionary<NSString *, id> *)extraAssets {
    return nil;
}
@end
