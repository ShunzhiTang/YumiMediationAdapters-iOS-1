//
//  AdsYuMiStartAppBannerAdapter.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMiStartAppBannerAdapter.h"
#import <StartApp/STABannerSize.h>
#import <StartApp/STABannerView.h>

@implementation AdsYuMiStartAppBannerAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdStartApp;
}

+ (void)load {
    [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
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

    STABannerSize size = STA_PortraitAdSize_320x50;
    switch (self.adType) {
        case AdViewYMTypeUnknown:
        case AdViewYMTypeNormalBanner:
            size = STA_PortraitAdSize_320x50;
            break;
        case AdViewYMTypeMediumBanner:
            size = STA_LandscapeAdSize_480x50;
            break;
        case AdViewYMTypeiPadNormalBanner:
            size = STA_PortraitAdSize_768x90;
            break;
        case AdViewYMTypeLargeBanner:
            size = STA_LandscapeAdSize_1024x90;
            break;
        default:
            [self adapter:self didFailAd:nil];
            break;
    }

    if (self.IsAutoAdSize) { //自适应
        size = STA_AutoAdSize;
    }

    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = self.provider.key1;
    if (bannerView == nil) {
        bannerView = [[STABannerView alloc] initWithSize:size
                                                  origin:self.adNetworkView.center
                                                withView:[self viewControllerForPresentModalView].view
                                            withDelegate:self];
    }
    self.adNetworkView = bannerView;
}

- (void)stopAd {
    [self stopTimer];
}

- (void)timeOutTimer {

    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"startApp timeout"]];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - StartAppBannerView Delegate
- (void)didDisplayBannerAd:(STABannerView *)banner {
    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didReceiveAdView:self.adNetworkView];
}
- (void)failedLoadBannerAd:(STABannerView *)banner withError:(NSError *)error {
    if (isStop || isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"startApp no ad"]];
}
- (void)didClickBannerAd:(STABannerView *)banner {
    [self pauseAdapter:self];
    [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}
- (void)didCloseBannerInAppStore:(STABannerView *)banner {
    [self continueAdapter:self];
}

- (void)dealloc {
    if (bannerView) {
        bannerView = nil;
    }
}

@end
