//
//  AdsYuMIAdNetworkInterstitialFacebookAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdapter.h"

#import <FBAudienceNetwork/FBInterstitialAd.h>

@interface AdsYuMIAdNetworkInterstitialFacebookAdapter : AdsYuMIAdNetworkAdapter <FBInterstitialAdDelegate>
{
  NSTimer * timer;
  
  BOOL isReading;

}

@property(nonatomic,retain)FBInterstitialAd *interstitial;

@end
