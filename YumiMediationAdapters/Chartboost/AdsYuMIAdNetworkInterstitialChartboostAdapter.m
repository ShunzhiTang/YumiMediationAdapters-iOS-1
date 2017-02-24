//
//  AdsYuMIAdNetworkInterstitialChartboostAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/28.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialChartboostAdapter.h"

@implementation AdsYuMIAdNetworkInterstitialChartboostAdapter


+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdChartboost;
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
 
  [Chartboost startWithAppId:self.provider.key1 appSignature:self.provider.key2 delegate:self];
  [Chartboost cacheInterstitial:CBLocationHomeScreen];
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
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Chartboost time out"]];
}


-(void)preasentInterstitial{
  if ([Chartboost hasInterstitial:CBLocationHomeScreen]) {
      [Chartboost showInterstitial:CBLocationHomeScreen];
  }
}

#pragma mark - ChartboostDelegate

//

- (BOOL)shouldRequestInterstitial:(CBLocation)location {
  return YES;
}

- (void)didCacheInterstitial:(NSString *)location {
  if (isReading) {
    return;
  }
  isReading=YES;
  
  [self stopTimer];
  [self adapterDidInterstitialReceiveAd:self];
}

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Chartboost no ad"]];
}

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
  [self adapterInterstitialDidPresentScreen:self];
  return YES;
}

- (void)didDismissInterstitial:(NSString *)location {
  [self adapterInterstitialDidDismissScreen:self];
}

- (void)didClickInterstitial:(CBLocation)location {
  [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

 
@end
