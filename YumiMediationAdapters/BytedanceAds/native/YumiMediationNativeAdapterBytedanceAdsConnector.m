//
//  YumiMediationNativeAdapterBytedanceAdsConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on  23/05/2019.
//

#import "YumiMediationNativeAdapterBytedanceAdsConnector.h"
#import <YumiMediationSDK/YumiTime.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationNativeAdapterBytedanceAdsConnector ()<BUVideoAdViewDelegate>

@property (nonatomic) BUNativeAd *buNativeAdData;
@property (nonatomic) YumiMediationNativeAdImage *icon;
@property (nonatomic) YumiMediationNativeAdImage *coverImage;
@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;
/// media view
@property (nonatomic) id<YumiMediationNativeAdapterConnectorMediaDelegate> mediaDelegate;
@property (nonatomic) YumiMediationNativeVideoController *videoController;

@end

@implementation YumiMediationNativeAdapterBytedanceAdsConnector

- (void)convertWithNativeData:(nullable BUNativeAd *)buNativeAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {
    self.adapter = adapter;
    self.buNativeAdData = buNativeAdData;
    self.connectorDelegate = connectorDelegate;

    NSString *iconUrl = self.buNativeAdData.data.icon.imageURL;
    NSString *coverImageUrl = nil;
    if (self.buNativeAdData.data.imageAry.count > 0) {
         coverImageUrl = self.buNativeAdData.data.imageAry[0].imageURL;
    }
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
    //TODO BytedanceAds no methods of control play or pause
}

/// Pause the video. Doesn't do anything if the video is already paused.
- (void)pause {
}

/// Returns the video's aspect ratio (width/height) or 0 if no video is present.
- (double)aspectRatio {
    return 0;
}

- (void)setConnectorMediaDelegate:(id<YumiMediationNativeAdapterConnectorMediaDelegate>)mediaDelegate {
    self.mediaDelegate = mediaDelegate;
}

#pragma mark: BUVideoAdViewDelegate

- (void)setNativeAdRelatedView:(BUNativeAdRelatedView *)nativeAdRelatedView{
    _nativeAdRelatedView = nativeAdRelatedView;
    _nativeAdRelatedView.videoAdView.delegate = self;
    _nativeAdRelatedView.videoAdView.drawVideoClickEnable = YES;
}

- (void)videoAdView:(BUVideoAdView *)videoAdView didLoadFailWithError:(NSError *_Nullable)error{
    
}

- (void)videoAdView:(BUVideoAdView *)videoAdView stateDidChanged:(BUPlayerPlayState)playerState{
    if (playerState == BUPlayerStatePlaying) {
        if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPlayVideo:)]) {
            [self.mediaDelegate adapterConnectorVideoDidPlayVideo:self];
        }
    }
    if (playerState == BUPlayerStatePause) {
        if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPauseVideo:)]) {
            [self.mediaDelegate adapterConnectorVideoDidPauseVideo:self];
        }
    }
}

- (void)playerDidPlayFinish:(BUVideoAdView *)videoAdView{
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidEndVideoPlayback:)]) {
        [self.mediaDelegate adapterConnectorVideoDidEndVideoPlayback:self];
    }
}

#pragma mark : YumiMediationUnifiedNativeAd
- (NSString *)title {
    return self.buNativeAdData.data.AdTitle;
}
- (NSString *)desc {
    return self.buNativeAdData.data.AdDescription;
}

- (NSString *)callToAction {
    return self.buNativeAdData.data.buttonText;
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
    return [NSString stringWithFormat:@"%ld",self.buNativeAdData.data.score];
}
- (NSString *)other {
    return nil;
}

- (id)data {
    return self.buNativeAdData;
}

- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}

- (NSDictionary<NSString *, id> *)extraAssets {
    return @{adapterConnectorKey : self};
}
- (BOOL)hasVideoContent {
    return self.buNativeAdData.data.imageMode == BUFeedVideoAdModeImage || self.buNativeAdData.data.imageMode == BUFeedVideoAdModePortrait;
}
- (YumiMediationNativeVideoController *)videoController {
    if (!_videoController) {
        _videoController = [[YumiMediationNativeVideoController alloc] init];
        // set value to connector
        [_videoController setValue:self forKey:@"connector"];
    }

    return _videoController;
}
@end
