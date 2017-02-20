//
//  AdsYuMIAdNetworkInterstitialFacebookAdapter.m
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialFacebookAdapter.h"

@implementation AdsYuMIAdNetworkInterstitialFacebookAdapter

+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdFacebook;
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

  
  self.interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.provider.key1];
  // Set a delegate to get notified on changes or when the user interact with the ad.
  self.interstitial.delegate = self;
  // Initiate the request to load the ad.
  [self.interstitial loadAd];
  
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
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Facebook time out"]];
}

-(void)preasentInterstitial{
  if (self.interstitial.isAdValid) {
    [self.interstitial showAdFromRootViewController:[[[UIApplication sharedApplication]keyWindow]rootViewController]];
  }
}


#pragma mark - FBInterstitialAdDelegate implementation
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd{
  if (isReading) {
    return;
  }
  isReading=YES;
   [self stopTimer];
  [self adapterDidInterstitialReceiveAd:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
  if (isReading) {
    return;
  }
  isReading=YES;
   [self stopTimer];
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Facebook no ad"]];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
  [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
  [self adapterInterstitialDidDismissScreen:self];
}

-(void)dealloc
{
  if (_interstitial) {
    _interstitial.delegate=nil;
    _interstitial=nil;
  }
}


@end
