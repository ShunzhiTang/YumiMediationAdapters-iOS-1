//
//  YumiMediationNativeAdapterGDTConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/1.
//

#import "YumiMediationNativeAdapterGDTConnector.h"
#import "GDTNativeExpressAdView.h"
#import <YumiMediationSDK/YumiTime.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationNativeAdapterGDTConnector () <GDTUnifiedNativeAdViewDelegate>

@property (nonatomic) GDTUnifiedNativeAdDataObject *gdtNativeAdData;
@property (nonatomic) YumiMediationNativeAdImage *icon;
@property (nonatomic) YumiMediationNativeAdImage *coverImage;
@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;
@property (nonatomic) YumiMediationNativeVideoController *videoController;

@property (nonatomic) GDTNativeExpressAdView *currentExpressAdView;

@end

@implementation YumiMediationNativeAdapterGDTConnector

- (void)convertWithNativeData:(id)gdtAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {
    self.adapter = adapter;
    self.connectorDelegate = connectorDelegate;

    if ([gdtAdData isKindOfClass:[GDTNativeExpressAdView class]]) {
        self.currentExpressAdView = gdtAdData;
        [self notifyCompletionWithResult:YES];
        return;
    }

    self.gdtNativeAdData = gdtAdData;

    NSString *iconUrl = ((GDTUnifiedNativeAdDataObject *)gdtAdData).iconUrl;
    NSString *coverImageUrl = ((GDTUnifiedNativeAdDataObject *)gdtAdData).imageUrl;
    [self downloadIcon:iconUrl
                 coverImage:coverImageUrl
        disableImageLoading:disableImageLoading
                  completed:^(BOOL isSuccessed) {
                      [self notifyCompletionWithResult:isSuccessed];
                  }];
}

- (void)setGdtNativeView:(GDTUnifiedNativeAdView *)gdtNativeView {
    _gdtNativeView = gdtNativeView;
    _gdtNativeView.delegate = self;
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
    [nativeModel setValue:@([[YumiTime timestamp] doubleValue]) forKey:@"timestamp"];

    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdSuccessful:)]) {
        [self.connectorDelegate yumiMediationNativeAdSuccessful:nativeModel];
    }
}

- (void)notifyMediatedNativeAdFailed {
    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdFailed)]) {
        [self.connectorDelegate yumiMediationNativeAdFailed];
    }
}

#pragma mark : YumiMediationNativeAdapterConnectorMedia
/// Play the video. Doesn't do anything if the video is already playing.
- (void)play {
}

/// Pause the video. Doesn't do anything if the video is already paused.
- (void)pause {
}

/// Returns the video's aspect ratio (width/height) or 0 if no video is present.
- (double)aspectRatio {
    return 0;
}

- (void)setConnectorMediaDelegate:(id<YumiMediationNativeAdapterConnectorMediaDelegate>)mediaDelegate {
}

#pragma mark : - GDTUnifiedNativeAdViewDelegate

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
}

- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.connectorDelegate yumiMediationNativeAdDidClick:nil];
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
}
- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView
            playerStatusChanged:(GDTMediaPlayerStatus)status
                       userInfo:(NSDictionary *)userInfo {
}

#pragma mark : YumiMediationUnifiedNativeAd
- (NSString *)title {
    return self.gdtNativeAdData.title;
}
- (NSString *)desc {
    return self.gdtNativeAdData.desc;
}

- (NSString *)callToAction {
    if (self.currentExpressAdView) {
        return nil;
    }
    if (self.gdtNativeAdData.isAppAd) {
        if ([[YumiTool sharedTool] iSSimplifiedChinese]) {
            return @"点击下载";
        }
        return @"Download";
    }

    if ([[YumiTool sharedTool] iSSimplifiedChinese]) {
        return @"查看详情";
    }
    return @"Learn More";
}
- (NSString *)appPrice {
    return [NSString stringWithFormat:@"%@", self.gdtNativeAdData.appPrice];
}
- (NSString *)advertiser {
    return nil;
}
- (NSString *)store {
    return nil;
}
- (NSString *)appRating {
    return [NSString stringWithFormat:@"%lf", self.gdtNativeAdData.appRating];
}
- (NSString *)other {
    return nil;
}

- (id)data {
    if (self.currentExpressAdView) {
        return self.currentExpressAdView;
    }
    return self.gdtNativeAdData;
}

- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}

- (NSDictionary<NSString *, id> *)extraAssets {
    return @{adapterConnectorKey : self};
}
- (BOOL)hasVideoContent {
    if (self.currentExpressAdView) {

        return self.currentExpressAdView.isVideoAd;
    }
    return self.gdtNativeAdData.isVideoAd;
}
- (YumiMediationNativeVideoController *)videoController {
    if (!_videoController) {
        _videoController = [[YumiMediationNativeVideoController alloc] init];
        // set value to connector
        [_videoController setValue:self forKey:@"connector"];
    }

    return _videoController;
}

- (UIView *)expressAdView {
    return self.currentExpressAdView;
}

- (BOOL)isExpressAdView {

    return self.currentExpressAdView != nil;
}

- (NSString *)specifiedProvider {
    return kYumiMediationAdapterIDGDT;
}

@end
