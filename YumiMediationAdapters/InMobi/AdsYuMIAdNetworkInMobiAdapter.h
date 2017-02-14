//
//  AdsYuMIAdNetworkInMobiAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/20.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <InMobiSDK/InMobiSDK.h>

@interface AdsYuMIAdNetworkInMobiAdapter : AdsYuMIAdNetworkAdapter <IMBannerDelegate>
{
  BOOL isStop;
  NSTimer *timer;
  BOOL   isReading;
  IMBanner *_adview;
}

@end
