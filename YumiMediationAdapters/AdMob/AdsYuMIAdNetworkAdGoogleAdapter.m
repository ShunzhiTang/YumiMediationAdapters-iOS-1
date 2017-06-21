//
//  AdsYuMIAdNetworkAdGoogleAdapter.m
//  AdsYUMISample
//
//  Created by wxl on 15/8/24.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdGoogleAdapter.h"

@implementation AdsYuMIAdNetworkAdGoogleAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdGoogle;
}

+ (void)load {
    [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;

    if (!_bannerView) {

        GADAdSize size = kGADAdSizeBanner;

        switch (self.adType) {
            case AdViewYMTypeUnknown:
            case AdViewYMTypeNormalBanner:
            case AdViewYMTypeiPadNormalBanner:
                size = kGADAdSizeBanner;
                break;
            case AdViewYMTypeRectangle:
                size = kGADAdSizeMediumRectangle;
                break;
            case AdViewYMTypeMediumBanner:
                size = kGADAdSizeFullBanner;
                break;
            case AdViewYMTypeLargeBanner:
                size = kGADAdSizeLeaderboard;
                break;
            default:
                [self adapter:self
                    didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Admob time out"]];
                break;
        }

        [self adDidStartRequestAd];

        id _timeInterval = self.provider.outTime;
        if ([_timeInterval isKindOfClass:[NSNumber class]]) {
            timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                     target:self
                                                   selector:@selector(timeOutTimer)
                                                   userInfo:nil
                                                    repeats:NO];
        } else {
            timer = [NSTimer scheduledTimerWithTimeInterval:8
                                                     target:self
                                                   selector:@selector(timeOutTimer)
                                                   userInfo:nil
                                                    repeats:NO];
        }

        if (self.IsAutoAdSize) { //自适应
            size = GADAdSizeFullWidthPortraitWithHeight([self getAutoAdSize].height);
        }
        _bannerView = [[GADBannerView alloc] initWithAdSize:size];
        [_bannerView setAdUnitID:self.provider.key1];
        self.adNetworkView = _bannerView;
    }

    [_bannerView setRootViewController:[self viewControllerForPresentModalView]];
    [_bannerView setDelegate:self];
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
}

- (void)stopAd {
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)timeOutTimer {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Admob time out"]];
}

#pragma mark Ad Request Lifecycle Notifications
/// Called when an ad request loaded an ad. This is a good opportunity to add this view to the
/// hierarchy if it has not been added yet. If the ad was received as a part of the server-side auto
/// refreshing, you can examine the hasAutoRefreshed property of the view.
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    if (isStop) {
        return;
    }

    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self didReceiveAdView:self.adNetworkView];
}

/// Called when an ad request failed. Normally this is because no network connection was available
/// or no ads were available (i.e. no fill). If the error was received as a part of the server-side
/// auto refreshing, you can examine the hasAutoRefreshed property of the view.
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Admob no ad"]];
}

#pragma mark Click-Time Lifecycle Notifications

/// Called just before presenting the user a full screen view, such as a browser, in response to
/// clicking on an ad. Use this opportunity to stop animations, time sensitive interactions, etc.
///
/// Normally the user looks at the ad, dismisses it, and control returns to your application by
/// calling adViewDidDismissScreen:. However if the user hits the Home button or clicks on an App
/// Store link your application will end. On iOS 4.0+ the next method called will be
/// applicationWillResignActive: of your UIViewController
/// (UIApplicationWillResignActiveNotification). Immediately after that adViewWillLeaveApplication:
/// is called.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
}

/// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
}

/// Called just after dismissing a full screen view. Use this opportunity to restart anything you
/// may have stopped as part of adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

- (void)dealloc {
    if (self.adNetworkView) {
        GADBannerView *_adMobView = (GADBannerView *)_bannerView;
        if (_adMobView != nil) {
            [_adMobView performSelector:@selector(setDelegate:) withObject:nil];
            _adMobView.delegate = nil;
            [_adMobView performSelector:@selector(setRootViewController:) withObject:nil];
        }
    }
}

@end
