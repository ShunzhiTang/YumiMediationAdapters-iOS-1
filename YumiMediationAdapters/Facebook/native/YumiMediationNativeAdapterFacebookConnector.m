//
//  YumiMediationNativeAdapterFacebookConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/13.
//

#import "YumiMediationNativeAdapterFacebookConnector.h"
#import <YumiMediationSDK/YumiTime.h>

@interface YumiMediationNativeAdapterFacebookConnector ()<FBMediaViewDelegate>

@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;
@property (nonatomic) FBNativeAd *fbNativeAd;
/// media view
@property (nonatomic) id<YumiMediationNativeAdapterConnectorMediaDelegate> mediaDelegate;
@property(nonatomic) YumiMediationNativeVideoController *videoController;

@end

@implementation YumiMediationNativeAdapterFacebookConnector

- (void)convertWithNativeData:(nullable FBNativeAd *)fbNativeAd
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {

    self.fbNativeAd = fbNativeAd;
    self.adapter = adapter;
    self.connectorDelegate = connectorDelegate;

    [self notifyMediatedNativeAdSuccessful];
}
- (void)notifyMediatedNativeAdSuccessful {
    YumiMediationNativeModel *nativeModel = [[YumiMediationNativeModel alloc] init];
    [nativeModel setValue:self forKey:@"unifiedNativeAd"];
    [nativeModel setValue:@([[YumiTime timestamp] doubleValue]) forKey:@"timestamp"];
    
    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdSuccessful:)]) {
        [self.connectorDelegate yumiMediationNativeAdSuccessful:nativeModel];
    }
}
#pragma mark: YumiMediationNativeAdapterConnectorMedia
/// Play the video. Doesn't do anything if the video is already playing.
///this unavailable
- (void)play{
    [self.mediaView.videoRenderer playVideo];
}

/// Pause the video. Doesn't do anything if the video is already paused.
///this unavailable
- (void)pause{
    [self.mediaView.videoRenderer pauseVideo];
}

/// Returns the video's aspect ratio (width/height) or 0 if no video is present.
- (double)aspectRatio{
    return self.mediaView.aspectRatio;
}

- (void)setConnectorMediaDelegate:(id<YumiMediationNativeAdapterConnectorMediaDelegate>)mediaDelegate{
    self.mediaDelegate = mediaDelegate;
}

#pragma mark : YumiMediationUnifiedNativeAd
- (YumiMediationNativeAdImage *)icon {

    YumiMediationNativeAdImage *icon = [[YumiMediationNativeAdImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
    UIImage *graphicsImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [icon setValue:graphicsImg forKey:@"image"];

    return icon;
}
- (YumiMediationNativeAdImage *)coverImage {
    YumiMediationNativeAdImage *coverImage = [[YumiMediationNativeAdImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
    UIImage *graphicsImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [coverImage setValue:graphicsImg forKey:@"image"];

    return coverImage;
}
- (NSString *)title {
   // sdk version above 4.99 ,must dispaly advertiserName
    return self.fbNativeAd.advertiserName;
}
- (NSString *)desc {
    return self.fbNativeAd.bodyText;
}
- (NSString *)callToAction {
    return self.fbNativeAd.callToAction;
}
- (NSString *)appPrice {
    return nil;
}
- (NSString *)advertiser {
    return self.fbNativeAd.advertiserName;
}
- (NSString *)store {
    return nil;
}
- (NSString *)appRating {
    return nil;
}
- (NSString *)other {
    return nil;
}
- (id)data {
    return self.fbNativeAd;
}
- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}
- (NSDictionary<NSString *, id> *)extraAssets {
    return nil;
}
- (BOOL)hasVideoContent{
    return self.fbNativeAd.adFormatType == FBAdFormatTypeVideo;
}
- (YumiMediationNativeVideoController *)videoController{
    if (!_videoController) {
        _videoController = [[YumiMediationNativeVideoController alloc] init];
        // set value to connector
        [_videoController setValue:self forKey:@"connector"];
        
    }
    
    return _videoController;
}

- (void)setMediaView:(FBMediaView *)mediaView{
    _mediaView = mediaView;
    
    _mediaView.delegate = self;
    
}

#pragma mark: FBMediaViewDelegate

- (void)mediaViewVideoDidPlay:(FBMediaView *)mediaView{
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPlayVideo:)]   ) {
        [self.mediaDelegate adapterConnectorVideoDidPlayVideo:self];
    }
}
- (void)mediaViewVideoDidPause:(FBMediaView *)mediaView{
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPauseVideo:)]   ) {
        [self.mediaDelegate adapterConnectorVideoDidPauseVideo:self];
    }
}

- (void)mediaViewVideoDidComplete:(FBMediaView *)mediaView{
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidEndVideoPlayback:)]   ) {
        [self.mediaDelegate adapterConnectorVideoDidEndVideoPlayback:self];
    }
}

@end
