//
//  AdsYuMIAdNetworkGDTAdapter.m
//  AdsYUMISample
//
//  Created by Castiel Chen on 15/8/18.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkGDTAdapter.h"
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)


@implementation AdsYuMIAdNetworkGDTAdapter

+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdGDT;
}
+ (void)load {
  [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

-(void)getAd{
  
  isReading=NO;
  [self adDidStartRequestAd];
  
  CGSize size = CGSizeZero;
  switch (self.adType) {
    case AdViewYMTypeNormalBanner:
    case AdViewYMTypeiPadNormalBanner:
      size = GDTMOB_AD_SUGGEST_SIZE_320x50;
      break;
    case AdViewYMTypeLargeBanner:
      size = GDTMOB_AD_SUGGEST_SIZE_728x90;
      break;
    case AdViewYMTypeMediumBanner:
      size = GDTMOB_AD_SUGGEST_SIZE_468x60;
      break;
    default:
      [self adapter:self didFailAd:nil];
      break;
  }
  
  id _timeInterval = self.provider.outTime;
  if ([_timeInterval isKindOfClass:[NSNumber class]]) {
    timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(timeOutTimer) userInfo:nil repeats:NO];
  }
  else{
    timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(timeOutTimer) userInfo:nil repeats:NO];
  }
  
  
  self.gdtAdView=[[GDTMobBannerView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height) appkey:self.provider.key1 placementId:self.provider.key2];
  self.adNetworkView=self.gdtAdView;
  [self.gdtAdView setCurrentViewController:[self viewControllerForPresentModalView]];
  self.gdtAdView.interval=0;
  self.gdtAdView.isAnimationOn=NO;
  self.gdtAdView.showCloseBtn=NO;

  
  if (IS_OS_7_OR_LATER) {
    self.gdtAdView.currentViewController.extendedLayoutIncludesOpaqueBars = NO;
    self.gdtAdView.currentViewController.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
  }
  
  [self.gdtAdView setDelegate:self];
  [self.gdtAdView loadAdAndShow];
}

-(void)stopAd{
  [self stopTimer];
}

-(void)timeOutTimer{
  
  if (isReading) {
    return;
  }
  isReading=YES;
  
  [self stopTimer];
  [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"GDT time out"]];
}


- (void)stopTimer {
  if (timer) {
    [timer invalidate];
    timer = nil;
  }
}

#pragma mark GDT Delegate
/**
 *  请求广告条数据成功后调用
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)bannerViewDidReceived{
  if (isReading) {
    return;
  }
  [self stopTimer];
  isReading=YES;
  [self adapter:self didReceiveAdView:self.adNetworkView];
  
}

/**
 *  请求广告条数据失败后调用
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)bannerViewFailToReceived:(NSError *)error{
  if (isReading) {
    return;
  }
  [self stopTimer];
  isReading=YES;
  [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

/**
 *  banner条点击回调
 */
- (void)bannerViewClicked{
  [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}


- (void)dealloc
{
  if (self.gdtAdView) {
    self.gdtAdView.delegate = nil;
    self.gdtAdView = nil;
  }
}



@end
