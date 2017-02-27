//
//  AdsYuMIAdNetworkInterstitialBaiduAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialBaiduAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>

@implementation AdsYuMIAdNetworkInterstitialBaiduAdapter


+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdBaiDu;
}

+ (void)load {
  [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

-(void)getAd{
  
  isReading = NO;
  [self adapterDidStartInterstitialRequestAd];
  
  [BaiduMobAdSetting sharedInstance].supportHttps = YES;
 
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
  
    selfBaiduAdapter =self;
  
  _baiduInterstitial = [[BaiduMobAdInterstitial alloc] init];
  _baiduInterstitial.delegate = self;
  _baiduInterstitial.AdUnitTag  = self.provider.key2;
  _baiduInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
  [_baiduInterstitial load];

}

/**
 *  停止展示广告
 */
-(void)stopAd{
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
-(void)timeOutTimer{
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"baidu ad time out"]];
}
/**
 *  插屏展示
 */
-(void)preasentInterstitial{
  if (self.baiduInterstitial.isReady){
  [self.baiduInterstitial presentFromRootViewController:[self viewControllerForWillPresentInterstitialModalView]];
  }
}

/**
 *  应用的APPID
 */
- (NSString *)publisherId;
{
  return self.provider.key1;
}


#pragma mark BaiduMobAdInterstitialDelegate

/**
 *  广告预加载成功#0	0x001182fa in -[AdsYuMIAdNetworkInterstitialBaiduAdapter interstitialSuccessToLoadAd:] at /Users/wxl/Documents/Zplay_Project/YMMergeSDK_Great/AdsYuMISDK/AdsYuMISDK/AdNetworkLibs/Baidu_SDK_v4.4/YUMIAdapter/AdsYuMIAdNetworkInterstitialBaiduAdapter.m:102

 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)_interstitial{
  if (isReading) {
    return;
  }
  isReading=YES;
   [self stopTimer];
  
  if (selfBaiduAdapter) {
    [selfBaiduAdapter adapterDidInterstitialReceiveAd:self];
  }
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)_interstitial{
  if (isReading) {
    return;
  }
  isReading=YES;
   [self stopTimer];
  [self adapter:self didInterstitialFailAd:nil];
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)_interstitial{
  [self adapterInterstitialWillPresentScreen:self];
}


/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)_interstitial withError:(BaiduMobFailReason) reason{
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"baidu not ad"]];
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)_interstitial{
  [self adapterInterstitialDidDismissScreen:self];
}

/**
 广告被点击
 *
 */
- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial{
  if (selfBaiduAdapter) {
    [selfBaiduAdapter adapterDidInterstitialClick:self ClickArea:CGRectZero];
  }
}

-(void)dealloc
{
  if (_baiduInterstitial) {
    [_baiduInterstitial setDelegate:nil];
    _baiduInterstitial = nil;
  }
  if (selfBaiduAdapter) {
    selfBaiduAdapter = nil;
  }
}

@end
