//
//  AdsYuMIAdNetworkInterstitialInMobiAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <InMobiSDK/InMobiSDK.h>

@interface AdsYuMIAdNetworkInterstitialInMobiAdapter : AdsYuMIAdNetworkAdapter <IMInterstitialDelegate>
{
  NSTimer * timer;
  BOOL isReading;
}
@property(nonatomic,strong)IMInterstitial *interstitialAd;

@end
