//
//  AdsYuMIAdNetworkBaiduAdapter.h
//  AdsYUMISample
//
//  Created by Castiel Chen on 15/8/17.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>

@interface AdsYuMIAdNetworkBaiduAdapter : AdsYuMIAdNetworkAdapter <BaiduMobAdViewDelegate>
{
  NSTimer *timer;
  BOOL isReading;
  BaiduMobAdView* sBaiduAdview;
  AdsYuMIAdNetworkBaiduAdapter * selfAdapter;
}
@end
