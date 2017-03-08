//
//  AdsYuMIAdNetworkInterstitialInMobiAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialInMobiAdapter.h"
#import <InMobiSDK/InMobiSDK.h>

@implementation AdsYuMIAdNetworkInterstitialInMobiAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdInMobi;
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

    [IMSdk initWithAccountID:self.provider.key1];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    long long placementId = [self.provider.key2 longLongValue];
    _interstitialAd = [[IMInterstitial alloc] initWithPlacementId:placementId delegate:self];
    [_interstitialAd load];
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
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Inmobi time out"]];
}

- (void)preasentInterstitial {
    if ([_interstitialAd isReady]) {
        [_interstitialAd showFromViewController:[self viewControllerForWillPresentInterstitialModalView]];
    }
}

#pragma mark Interstitial Interaction Notifications

/**
 * The interstitial has finished loading
 */
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapterDidInterstitialReceiveAd:self];
}
/**
 * The interstitial has failed to load with some error.
 */
- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
}
/**
 * The interstitial would be presented.
 */
- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    [self adapterInterstitialWillPresentScreen:self];
}
/**
 * The interstitial has been presented.
 */
- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
}
/**
 * The interstitial has failed to present with some error.
 */
- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
}
/**
 * The interstitial will be dismissed.
 */
- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
}
/**
 * The interstitial has been dismissed.
 */
- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    [self adapterInterstitialDidDismissScreen:self];
}
/**
 * The interstitial has been interacted with.
 */
- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}
/**
 * The user has performed the action to be incentivised with.
 */
- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
}
/**
 * The user will leave application context.
 */
- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
}

- (void)dealloc {
    if (_interstitialAd) {
        [_interstitialAd setDelegate:nil];
        _interstitialAd = nil;
    }
}

@end
