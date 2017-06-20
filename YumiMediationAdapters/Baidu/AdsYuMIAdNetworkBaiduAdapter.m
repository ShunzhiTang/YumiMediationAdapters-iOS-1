//
//  AdsYuMIAdNetworkBaiduAdapter.m
//  AdsYUMISample
//
//  Created by Castiel Chen on 15/8/17.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkBaiduAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>

@implementation AdsYuMIAdNetworkBaiduAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdBaiDu;
}

+ (void)load {
     [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    CGSize size = CGSizeZero;

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

    [BaiduMobAdSetting sharedInstance].supportHttps = YES;

    switch (self.adType) {
        case AdViewYMTypeUnknown:
        case AdViewYMTypeNormalBanner:
        case AdViewYMTypeiPadNormalBanner:
            size = kBaiduAdViewBanner320x48;
            break;
        case AdViewYMTypeRectangle:
            size = kBaiduAdViewSquareBanner300x250;
            break;
        case AdViewYMTypeMediumBanner:
            size = kBaiduAdViewBanner468x60;
            break;
        case AdViewYMTypeLargeBanner:
            size = kBaiduAdViewBanner728x90;
            break;
        default:
            [self adapter:self
                didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"baidu adtype does not exist"]];
            return;
    }

    selfAdapter = self;

    sBaiduAdview = [[BaiduMobAdView alloc] init];
    sBaiduAdview.AdType = BaiduMobAdViewTypeBanner;
    sBaiduAdview.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    sBaiduAdview.AdUnitTag = self.provider.key2;
    sBaiduAdview.delegate = self;
    [sBaiduAdview start];

    self.adNetworkView = sBaiduAdview;
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)stopAd {
    isReading = YES;
    [self stopTimer];
}

- (void)timeOutTimer {
    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"baidu ad time out"]];
}

/**
 *  应用在union.baidu.com上的APPID
 */
- (NSString *)publisherId {
    return self.provider.key1;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    if (isReading) {
        return;
    }
    [selfAdapter adapter:self didReceiveAdView:self.adNetworkView];
    isReading = YES;
    [self stopTimer];
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    if (isReading) {
        return;
    }

    if (BaiduMobFailReason_NOAD == reason) {
        [selfAdapter adapter:self
                   didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"baidu not ad"]];
    } else {
        [selfAdapter adapter:self didFailAd:nil];
    }
    isReading = YES;
    [self stopTimer];
}

- (void)didAdImpressed {
}

- (void)didAdClicked {
    [selfAdapter pauseAdapter:self];
    [selfAdapter adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

- (void)didDismissLandingPage {
    if (selfAdapter) {
        [selfAdapter continueAdapter:self];
    }
}

- (void)dealloc {
    if (sBaiduAdview) {
        sBaiduAdview.delegate = nil;
        sBaiduAdview = nil;
    }
    if (selfAdapter) {
        selfAdapter = nil;
    }
}

@end
