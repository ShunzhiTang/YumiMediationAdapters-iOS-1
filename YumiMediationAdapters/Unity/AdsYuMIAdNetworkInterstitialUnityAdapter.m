//
//  AdsYuMIAdNetworkInterstitialUnityAdapter.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 2017/2/6.
//  Copyright © 2017年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialUnityAdapter.h"

@implementation AdsYuMIAdNetworkInterstitialUnityAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdUnity;
}

+ (void)load {
    [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    [self adapterDidStartInterstitialRequestAd];

    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }

    [UnityAds initialize:self.provider.key1 delegate:self];
    [UnityAds setDebugMode:NO];
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
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Unity time out"]];
}

- (void)preasentInterstitial {
    if ([UnityAds isReady:self.provider.key2]) {
        [UnityAds show:[self viewControllerForWillPresentInterstitialModalView] placementId:self.provider.key2];
    }
}

#pragma MARK UnityDelegate
/**
 *  Called when `UnityAds` is ready to show an ad. After this callback you can call the `UnityAds` `show:` method for
 * this placement.
 *  Note that sometimes placement might no longer be ready due to exceptional reasons. These situations will give no new
 * callbacks.
 *
 *  @warning To avoid error situations, it is always best to check `isReady` method status before calling show.
 *  @param placementId The ID of the placement that is ready to show, as defined in Unity Ads admin tools.
 */
- (void)unityAdsReady:(NSString *)placementId {
    if ([placementId isEqualToString:self.provider.key2]) {
        if (isReading) {
            return;
        }
        isReading = YES;
        [self stopTimer];
        [self adapterDidInterstitialReceiveAd:self];
    }
}
/**
 *  Called when `UnityAds` encounters an error. All errors will be logged but this method can be used as an additional
 * debugging aid. This callback can also be used for collecting statistics from different error scenarios.
 *
 *  @param error   A `UnityAdsError` error enum value indicating the type of error encountered.
 *  @param message A human readable string indicating the type of error encountered.
 */
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Unity no ad"]];
}
/**
 *  Called on a successful start of advertisement after calling the `UnityAds` `show:` method.
 *
 * @warning If there are errors in starting the advertisement, this method may never be called. Unity Ads will directly
 * call `unityAdsDidFinish:withFinishState:` with error status.
 *
 *  @param placementId The ID of the placement that has started, as defined in Unity Ads admin tools.
 */
- (void)unityAdsDidStart:(NSString *)placementId {
    if ([placementId isEqualToString:self.provider.key2]) {
        [self adapterInterstitialDidPresentScreen:self];
    }
}
/**
 *  Called after the ad has closed.
 *
 *  @param placementId The ID of the placement that has finished, as defined in Unity Ads admin tools.
 *  @param state       An enum value indicating the finish state of the ad. Possible values are `Completed`, `Skipped`,
 * and `Error`.
 */
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if ([placementId isEqualToString:self.provider.key2]) {
        [self adapterInterstitialDidDismissScreen:self];
    }
}
@end
