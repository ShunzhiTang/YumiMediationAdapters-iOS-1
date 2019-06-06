//
//  YumiMediationNativeAdapterAdMobConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/11.
//

#import "YumiMediationNativeAdapterAdMobConnector.h"
#import <YumiMediationSDK/YumiMediationNativeVideoController.h>
#import <YumiMediationSDK/YumiTime.h>

@interface YumiMediationNativeAdapterAdMobConnector () <GADUnifiedNativeAdDelegate, GADVideoControllerDelegate>

@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;
@property (nonatomic) GADUnifiedNativeAd *gadNativeAd;
@property (nonatomic) YumiMediationNativeModel *nativeModel;
/// media view
@property (nonatomic) id<YumiMediationNativeAdapterConnectorMediaDelegate> mediaDelegate;
@property (nonatomic) YumiMediationNativeVideoController *videoController;

@end

@implementation YumiMediationNativeAdapterAdMobConnector

- (void)convertWithNativeData:(nullable GADUnifiedNativeAd *)gadNativeAd
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {

    self.gadNativeAd = gadNativeAd;
    self.adapter = adapter;
    self.connectorDelegate = connectorDelegate;
    self.gadNativeAd.delegate = self;
    self.gadNativeAd.mediaContent.videoController.delegate = self;
    [self notifyMediatedNativeAdSuccessful];
}

- (void)notifyMediatedNativeAdSuccessful {
    self.nativeModel = [[YumiMediationNativeModel alloc] init];
    [self.nativeModel setValue:self forKey:@"unifiedNativeAd"];
    [self.nativeModel setValue:@([[YumiTime timestamp] doubleValue]) forKey:@"timestamp"];

    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdSuccessful:)]) {
        [self.connectorDelegate yumiMediationNativeAdSuccessful:self.nativeModel];
    }
}

#pragma mark : GADUnifiedNativeAdDelegate
- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
}

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdDidClick:)]) {
        [self.connectorDelegate yumiMediationNativeAdDidClick:self.nativeModel];
    }
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
}

/// Called before dismissing a full screen view.
- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
}

/// Called after dismissing a full screen view. Use this opportunity to restart anything you may
/// have stopped as part of nativeAdWillPresentScreen:.
- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
}

#pragma mark : YumiMediationNativeAdapterConnectorMedia
/// Play the video. Doesn't do anything if the video is already playing.
- (void)play {
    [self.gadNativeAd.mediaContent.videoController play];
}

/// Pause the video. Doesn't do anything if the video is already paused.
- (void)pause {
    [self.gadNativeAd.mediaContent.videoController pause];
}

/// Returns the video's aspect ratio (width/height) or 0 if no video is present.
- (double)aspectRatio {
    return [self.gadNativeAd.mediaContent aspectRatio];
}

- (void)setConnectorMediaDelegate:(id<YumiMediationNativeAdapterConnectorMediaDelegate>)mediaDelegate {
    self.mediaDelegate = mediaDelegate;
}
#pragma mark : YumiMediationUnifiedNativeAd
- (YumiMediationNativeAdImage *)icon {
    GADNativeAdImage *gadIcon = self.gadNativeAd.icon;

    YumiMediationNativeAdImage *icon = [[YumiMediationNativeAdImage alloc] init];
    [icon setValue:gadIcon.image forKey:@"image"];
    [icon setValue:gadIcon.imageURL forKey:@"imageURL"];
    [icon setValue:@(gadIcon.scale) forKey:@"ratios"];

    return icon;
}
- (YumiMediationNativeAdImage *)coverImage {
    GADNativeAdImage *gadImg;
    if (self.gadNativeAd.images.count > 0) {
        gadImg = self.gadNativeAd.images[0];
    }
    YumiMediationNativeAdImage *coverImage = [[YumiMediationNativeAdImage alloc] init];
    [coverImage setValue:gadImg.image forKey:@"image"];
    [coverImage setValue:gadImg.imageURL forKey:@"imageURL"];
    [coverImage setValue:@(gadImg.scale) forKey:@"ratios"];

    return coverImage;
}
- (NSString *)title {
    return self.gadNativeAd.headline;
}
- (NSString *)desc {
    return self.gadNativeAd.body;
}
- (NSString *)callToAction {
    return self.gadNativeAd.callToAction;
}
- (NSString *)appPrice {
    return self.gadNativeAd.price;
}
- (NSString *)advertiser {
    return self.gadNativeAd.advertiser;
}
- (NSString *)store {
    return self.gadNativeAd.store;
}
- (NSString *)appRating {
    return [NSString stringWithFormat:@"%zd", [self.gadNativeAd.starRating integerValue]];
}
- (NSString *)other {
    return nil;
}
- (id)data {
    return self.gadNativeAd;
}
- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}
- (NSDictionary<NSString *, id> *)extraAssets {
    return nil;
}

- (BOOL)hasVideoContent {
    return self.gadNativeAd.mediaContent.hasVideoContent;
}
- (YumiMediationNativeVideoController *)videoController {
    if (!_videoController) {
        _videoController = [[YumiMediationNativeVideoController alloc] init];
        // set value to connector
        [_videoController setValue:self forKey:@"connector"];
    }

    return _videoController;
}

#pragma mark : GADVideoControllerDelegate
/// Tells the delegate that the video controller has began or resumed playing a video.
- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPlayVideo:)]) {
        [self.mediaDelegate adapterConnectorVideoDidPlayVideo:self];
    }
}

/// Tells the delegate that the video controller has paused video.
- (void)videoControllerDidPauseVideo:(GADVideoController *)videoController {
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidPauseVideo:)]) {
        [self.mediaDelegate adapterConnectorVideoDidPauseVideo:self];
    }
}

/// Tells the delegate that the video controller's video playback has ended.
- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
    if ([self.mediaDelegate respondsToSelector:@selector(adapterConnectorVideoDidEndVideoPlayback:)]) {
        [self.mediaDelegate adapterConnectorVideoDidEndVideoPlayback:self];
    }
}

@end
