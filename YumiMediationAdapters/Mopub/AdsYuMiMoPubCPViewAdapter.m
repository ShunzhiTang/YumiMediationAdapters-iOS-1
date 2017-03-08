//
//  AdsYuMiMoPubCPViewAdapter.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMiMoPubCPViewAdapter.h"

@implementation AdsYuMiMoPubCPViewAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdMopub;
}

+ (void)load {
    [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    isClick = NO;

    [self adapterDidStartInterstitialRequestAd];

    /*
    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
      timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                               target:self
                                             selector:@selector(timeOutTimer)
                                             userInfo:nil
                                              repeats:NO];
    }else {
      timer = [NSTimer scheduledTimerWithTimeInterval:15
                                               target:self
                                             selector:@selector(timeOutTimer)
                                             userInfo:nil
                                              repeats:NO];
    }
     */

    MPCPView = [MPInterstitialAdController interstitialAdControllerForAdUnitId:self.provider.key1];
    MPCPView.delegate = self;
    [MPCPView loadAd];
}

/**
 *  停止展示广告
 */
- (void)stopAd {
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

/**
 *  平台超时
 */
- (void)timeOutTimer {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Mopub time out"]];
}

- (void)preasentInterstitial {
    if (MPCPView.ready)
        [MPCPView showFromViewController:[self viewControllerForWillPresentInterstitialModalView]];
    else {
        // The interstitial wasn't ready, so continue as usual.
    }
}

#pragma mark - Mopub interstital  Delegate
/** @name Detecting When an Interstitial Ad is Loaded */

/**
 * Sent when an interstitial ad object successfully loads an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapterDidInterstitialReceiveAd:self];
}

/**
 * Sent when an interstitial ad object fails to load an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {

    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Mopub no ad"]];
}

/** @name Detecting When an Interstitial Ad is Presented */

/**
 * Sent immediately before an interstitial ad object is presented on the screen.
 *
 * Your implementation of this method should pause any application activity that requires user
 * interaction.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
}

/**
 * Sent after an interstitial ad object has been presented on the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
}

/** @name Detecting When an Interstitial Ad is Dismissed */

/**
 * Sent immediately before an interstitial ad object will be dismissed from the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
}

/**
 * Sent after an interstitial ad object has been dismissed from the screen, returning control
 * to your application.
 *
 * Your implementation of this method should resume any application activity that was paused
 * prior to the interstitial being presented on-screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    [self adapterInterstitialDidDismissScreen:self];
}

/** @name Detecting When an Interstitial Ad Expires */

/**
 * Sent when a loaded interstitial ad is no longer eligible to be displayed.
 *
 * Interstitial ads from certain networks (such as iAd) may expire their content at any time,
 * even if the content is currently on-screen. This method notifies you when the currently-
 * loaded interstitial has expired and is no longer eligible for display.
 *
 * If the ad was on-screen when it expired, you can expect that the ad will already have been
 * dismissed by the time this message is sent.
 *
 * Your implementation may include a call to `loadAd` to fetch a new ad, if desired.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
}

/**
 * Sent when the user taps the interstitial ad and the ad is about to perform its target action.
 *
 * This action may include displaying a modal or leaving your application. Certain ad networks
 * may not expose a "tapped" callback so you should not rely on this callback to perform
 * critical tasks.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    if (isClick) {
        return;
    }
    isClick = YES;
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

- (void)dealloc {
    if (MPCPView) {
        MPCPView.delegate = nil;
        MPCPView = nil;
    }
}

@end
