//
//  AdsYuMIAdNetworkInterstitialGDTAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialGDTAdapter.h"

@interface AdsYuMIAdNetworkInterstitialGDTAdapter () {
  AdsYuMIAdNetworkInterstitialGDTAdapter *_adsYuMIGDTSelf;
}

@end

@implementation AdsYuMIAdNetworkInterstitialGDTAdapter


+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdGDT;
}

+ (void)load {
  [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

-(void)getAd{
  
  isReading = NO;
  [self adapterDidStartInterstitialRequestAd];
  
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
  
  //self.provider.key1 = @"1105801907";
  //self.provider.key2 = @"9020917726355996";
  
  _interstitialObj = [[GDTMobInterstitial alloc] initWithAppkey:self.provider.key1 placementId:self.provider.key2];
  _interstitialObj.delegate = self;
  [_interstitialObj loadAd];
  
  _adsYuMIGDTSelf = self;
}

-(void)stopAd{
  [self stopTimer];
}

- (void)stopTimer {
  if (timer) {
    [timer invalidate];
    timer = nil;
  }
}

-(void)timeOutTimer{
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [_adsYuMIGDTSelf adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"GDT time out"]];
}

-(void)preasentInterstitial{
  [_interstitialObj presentFromRootViewController:[self viewControllerForWillPresentInterstitialModalView]];
}

#pragma mark - GDTMobInterstitialDelegate
/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
  if (isReading) {
    return;
  }
  isReading=YES;
  
  [self stopTimer];
  [_adsYuMIGDTSelf adapterDidInterstitialReceiveAd:self];
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial errorCode:(int)errorCode
{
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  
  [_adsYuMIGDTSelf adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

/**
 *  插屏广告将要展示回调
 *  详解: 插屏广告即将展示回调该函数
 */
- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial
{
  [_adsYuMIGDTSelf adapterInterstitialWillPresentScreen:self];
}

/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial
{
}


/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial{
  [_adsYuMIGDTSelf adapterInterstitialDidDismissScreen:self];
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial
{
}

/**
 *  插屏广告曝光时回调（一般指滚动的样式，每一个曝光都会调用，但每一个只调用一次）
 *  详解: 插屏广告曝光时回调
 */
-(void)interstitialWillExposure:(GDTMobInterstitial *)interstitial
{
}

/**
 *  插屏广告点击回调
 */
- (void)interstitialClicked:(GDTMobInterstitial *)interstitial
{
  [_adsYuMIGDTSelf adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

-(void)dealloc
{
  
  if (_interstitialObj) {
    [_interstitialObj setDelegate:nil];
    _interstitialObj = nil;
  }
}

@end
