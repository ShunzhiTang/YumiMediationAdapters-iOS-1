//
//  AdsYuMIAdNetworkInterstitialAppLovinAdapter.m
//  AdsYUMISample
//
//  Created by wxl on 15/11/5.
//  Copyright © 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkInterstitialAppLovinAdapter.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"

@interface AdsYuMIAdNetworkInterstitialAppLovinAdapter()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate> {

  BOOL isSecond;
}

@property (nonatomic, strong) ALInterstitialAd *interstitialAd;

@property (nonatomic, strong) ALAd *ad;

@property (nonatomic, strong) ALSdk *sdk;

@end

@implementation AdsYuMIAdNetworkInterstitialAppLovinAdapter

+ (NSString*)networkType{
  return AdsYuMIAdNetworkAdAppLovin;
}

+ (void)load {
  [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
  
}

-(void)getAd{
  
  isReading = NO;
  isSecond = NO;
  
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
  
  ALSdkSettings *settings = [ALSdkSettings alloc];
  [settings setAutoPreloadAdTypes: @"REWARD,REGULAR"];
  NSString *sdkKey = self.provider.key1;
  self.sdk = [ALSdk sharedWithKey:sdkKey settings:settings];


  self.interstitialAd = [[ALInterstitialAd alloc] initWithSdk:self.sdk];
  self.interstitialAd.adLoadDelegate = self;
  self.interstitialAd.adDisplayDelegate = self;
  [[self.sdk adService] loadNextAd:[ALAdSize sizeInterstitial] andNotify:self];

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
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Applovin time out"]];
}


-(void)preasentInterstitial{
  [self.interstitialAd showOver:[UIApplication sharedApplication].keyWindow.rootViewController.view.window andRender: self.ad];
}

#pragma mark - Ad Load Delegate

- (void)adService:(alnonnull ALAdService *)adService didLoadAd:(alnonnull ALAd *)ad
{
  self.ad = ad;
  
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [self adapterDidInterstitialReceiveAd:self];
}

- (void) adService:(alnonnull ALAdService *)adService didFailToLoadAdWithError:(int)code
{
  if (isReading) {
    return;
  }
  isReading=YES;
  [self stopTimer];
  [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Applovin no ad"]];
}

#pragma mark - Ad Display Delegate

- (void)ad:(alnonnull ALAd *)ad wasDisplayedIn:(alnonnull UIView *)view
{
  [self adapterInterstitialWillPresentScreen:self];
}

- (void)ad:(alnonnull ALAd *)ad wasHiddenIn:(alnonnull UIView *)view
{
  if (isSecond) {
    return;
  }
  isSecond = YES;
  [self adapterInterstitialDidDismissScreen:self];
}

- (void)ad:(alnonnull ALAd *)ad wasClickedIn:(alnonnull UIView *)view
{
  [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

#pragma mark - Ad Video Playback Delegate

- (void)videoPlaybackBeganInAd:(alnonnull ALAd *)ad {
  
}

- (void)videoPlaybackEndedInAd:(alnonnull ALAd *)ad atPlaybackPercent:(alnonnull NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {

}

- (void)dealloc {
  if (self.interstitialAd) {
    self.interstitialAd.adDisplayDelegate=nil;
    self.interstitialAd.adLoadDelegate = nil;
    self.interstitialAd=nil;
  }
}

@end
