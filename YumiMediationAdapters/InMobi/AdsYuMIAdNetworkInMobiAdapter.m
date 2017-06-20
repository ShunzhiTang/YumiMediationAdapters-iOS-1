//
//  AdsYuMIAdNetworkInMobiAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/20.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInMobiAdapter.h"
#import <Foundation/Foundation.h>
#import <InMobiSDK/InMobiSDK.h>

@implementation AdsYuMIAdNetworkInMobiAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdInMobi;
}

+ (void)load {
        [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    [self adDidStartRequestAd];

    isReading = NO;
    CGRect rect = CGRectZero;

    switch (self.adType) {
        case AdViewYMTypeNormalBanner:
        case AdViewYMTypeiPadNormalBanner:
            rect = CGRectMake(0, 0, 320, 50);
            break;
        case AdViewYMTypeRectangle:
            rect = CGRectMake(0, 0, 300, 250);
            break;
        case AdViewYMTypeMediumBanner:
            rect = CGRectMake(0, 0, 468, 60);
            break;
        case AdViewYMTypeLargeBanner:
            rect = CGRectMake(0, 0, 728, 90);
            break;
        default:
            [self adapter:self didFailAd:nil];
            break;
    }

    [IMSdk initWithAccountID:self.provider.key1];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

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

    long long placementId = [self.provider.key2 longLongValue];
    _adview = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)
                                  placementId:placementId
                                     delegate:self];
    self.adNetworkView = _adview;
    [_adview load];
}

- (void)stopAd {
    isStop = YES;
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)timeOutTimer {

    if (isStop || isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];

    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[IMBanner class]]) {
        [(IMBanner *)self.adNetworkView setDelegate:nil];
    }
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Inmobi time out"]];
}

#pragma mark InMobiAdDelegate methods

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didReceiveAdView:self.adNetworkView];
}
/**
 * The banner has failed to load with some error.
 */
- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
}
/**
 * The banner was interacted with.
 */
- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params {
}

#warning 为了解决点击回调不走，现在将点击回调移到跳转回调上面，内部跳转和外部跳转,下个版本更新inmobi SDK时记得换回来
/**
 * The user would be taken out of the application context.
 */
- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    [self adapter:self didClickAdView:nil WithRect:CGRectZero];
}
/**
 * The banner would be presenting a full screen content.
 */
- (void)bannerWillPresentScreen:(IMBanner *)banner {
    [self adapter:self didClickAdView:nil WithRect:CGRectZero];
}
/**
 * The banner has finished presenting screen.
 */
- (void)bannerDidPresentScreen:(IMBanner *)banner {
}
/**
 * The banner will start dismissing the presented screen.
 */
- (void)bannerWillDismissScreen:(IMBanner *)banner {
}
/**
 * The banner has dismissed the presented screen.
 */
- (void)bannerDidDismissScreen:(IMBanner *)banner {
}
/**
 * The user has completed the action to be incentivised with.
 */
- (void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
}

- (void)dealloc {
    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[IMBanner class]]) {
        [(IMBanner *)self.adNetworkView setDelegate:nil];
    }
}

@end
