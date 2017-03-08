//
//  AdsYuMiMoPubBannerViewAdapter.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMiMoPubBannerViewAdapter.h"

@implementation AdsYuMiMoPubBannerViewAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdMopub;
}

+ (void)load {
    [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isStop = NO;
    isReading = NO;

    [self adDidStartRequestAd];

    //  id _timeInterval = self.provider.outTime;
    //  if ([_timeInterval isKindOfClass:[NSNumber class]]) {
    //    timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self
    //    selector:@selector(timeOutTimer) userInfo:nil repeats:NO];
    //  }
    //  else{
    //    timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(timeOutTimer) userInfo:nil
    //    repeats:NO];
    //  }
    //

    CGSize adSize = CGSizeZero;

    switch (self.adType) {
        case AdViewYMTypeNormalBanner:
            adSize = MOPUB_BANNER_SIZE;
            break;
        case AdViewYMTypeLargeBanner:
            adSize = MOPUB_LEADERBOARD_SIZE;
            break;
        default:
            break;
    }

    // self.provider.key1 = @"55e382ae536a42068fd69420f70ff712";

    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
        MPView = [[MPAdView alloc] initWithAdUnitId:self.provider.key2 size:adSize];
        MPView.frame = CGRectMake(0, 0, MOPUB_LEADERBOARD_SIZE.width, MOPUB_LEADERBOARD_SIZE.height);
    } else {
        MPView = [[MPAdView alloc] initWithAdUnitId:self.provider.key1 size:adSize];
        MPView.frame = CGRectMake(0, 0, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    }
    MPView.delegate = self;
    [MPView loadAd];
    self.adNetworkView = MPView;
}

- (void)stopAd {
    isStop = YES;
    [self stopTimer];
}

- (void)timeOutTimer {

    if (isStop || isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[MPView class]]) {
        MPView.delegate = nil;
    }
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Mopub time out"]];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView {

    return [self viewControllerForPresentModalView];
}

/**
 * Sent when an ad view successfully loads an ad.
 *
 * Your implementation of this method should insert the ad view into the view hierarchy, if you
 * have not already done so.
 *
 * @param view The ad view sending the message.
 */
- (void)adViewDidLoadAd:(MPAdView *)view {
    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didReceiveAdView:self.adNetworkView];
}

/**
 * Sent when an ad view fails to load an ad.
 *
 * To avoid displaying blank ads, you should hide the ad view in response to this message.
 *
 * @param view The ad view sending the message.
 */
- (void)adViewDidFailToLoadAd:(MPAdView *)view {

    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Mopub no ad"]];
}

/** @name Detecting When a User Interacts With the Ad View */

/**
 * Sent when an ad view is about to present modal content.
 *
 * This method is called when the user taps on the ad view. Your implementation of this method
 * should pause any application activity that requires user interaction.
 *
 * @param view The ad view sending the message.
 * @see `didDismissModalViewForAd:`
 */
- (void)willPresentModalViewForAd:(MPAdView *)view {
    [self pauseAdapter:self];
    [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

/**
 * Sent when an ad view has dismissed its modal content, returning control to your application.
 *
 * Your implementation of this method should resume any application activity that was paused
 * in response to `willPresentModalViewForAd:`.
 *
 * @param view The ad view sending the message.
 * @see `willPresentModalViewForAd:`
 */
- (void)didDismissModalViewForAd:(MPAdView *)view {
    [self continueAdapter:self];
}

/**
 * Sent when a user is about to leave your application as a result of tapping
 * on an ad.
 *
 * Your application will be moved to the background shortly after this method is called.
 *
 * @param view The ad view sending the message.
 */
- (void)willLeaveApplicationFromAd:(MPAdView *)view {
}

- (void)dealloc {
    if (MPView) {
        MPView.delegate = nil;
        MPView = nil;
    }
}
@end
