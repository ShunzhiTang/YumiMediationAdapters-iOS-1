//
//  AdsYuMIAdNetworkInterstitialGDTAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdapter.h"
#import "GDTMobInterstitial.h"

@interface AdsYuMIAdNetworkInterstitialGDTAdapter : AdsYuMIAdNetworkAdapter <GDTMobInterstitialDelegate>
{
  GDTMobInterstitial *_interstitialObj;
  NSTimer * timer;
  BOOL  isReading;
}

@end
