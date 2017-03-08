//
//  AdsYuMIAdNetworkInterstitialGoogleAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialGoogleAdapter.h"

@implementation AdsYuMIAdNetworkInterstitialGoogleAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdGoogle;
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

    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.provider.key1];

    GADRequest *request = [GADRequest request];
    [self.interstitial setDelegate:self];

    [self.interstitial loadRequest:request];
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
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Admob time out"]];
}
- (void)preasentInterstitial {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:[self viewControllerForWillPresentInterstitialModalView]];
    }
}

#pragma mark - admob delegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapterDidInterstitialReceiveAd:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Admob no ad"]];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [self adapterInterstitialWillPresentScreen:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [self adapterInterstitialDidDismissScreen:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

- (void)dealloc {
    if (_interstitial) {
        [_interstitial setDelegate:nil];
        _interstitial = nil;
    }
}

@end
