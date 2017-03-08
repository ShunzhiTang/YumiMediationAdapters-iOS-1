//
//  AdsYuMiStartAppInitializationAdapter.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMiStartAppInitializationAdapter.h"

@interface AdsYuMiStartAppInitializationAdapter ()

@end

@implementation AdsYuMiStartAppInitializationAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdStartApp;
}

+ (void)load {
    [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    isClick = NO;
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

    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = self.provider.key1;
    startAppAd = [[STAStartAppAd alloc] init];
    [startAppAd loadAdWithDelegate:self];
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
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"startApp time out"]];
}
/**
 *  插屏展示
 */
- (void)preasentInterstitial {
    [startAppAd showAd];
}

/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)didLoadAd:(STAAbstractAd *)ad {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapterDidInterstitialReceiveAd:self];
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)failedLoadAd:(STAAbstractAd *)ad withError:(NSError *)error {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"startApp no ad"]];
}

/**
 *  插屏广告展示回调
 *  详解: 插屏广告展示回调该函数
 */
- (void)didShowAd:(STAAbstractAd *)ad {
    [self adapterInterstitialWillPresentScreen:self];
}

//插屏广告展示失败回调
- (void)failedShowAd:(STAAbstractAd *)ad withError:(NSError *)error {
}

/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)didCloseAd:(STAAbstractAd *)ad {
    if (isClick) {
        return;
    }
    isClick = YES;
    [self adapterInterstitialDidDismissScreen:self];
}

/**
 *  插屏广告点击回调
 */
- (void)didClickAd:(STAAbstractAd *)ad {
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
    if (isClick) {
        return;
    }
    isClick = YES;
    [self adapterInterstitialDidDismissScreen:self];
}

- (void)dealloc {
    if (startAppAd) {
        [startAppAd loadAdWithDelegate:nil];
        startAppAd = nil;
    }
}

@end
