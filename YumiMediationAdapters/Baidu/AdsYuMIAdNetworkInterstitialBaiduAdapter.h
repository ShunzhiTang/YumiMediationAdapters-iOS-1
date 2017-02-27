//
//  AdsYuMIAdNetworkInterstitialBaiduAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdapter.h"

#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>

@interface AdsYuMIAdNetworkInterstitialBaiduAdapter : AdsYuMIAdNetworkAdapter <BaiduMobAdInterstitialDelegate>
{
    NSTimer *timer;
    BOOL isReading;
  AdsYuMIAdNetworkInterstitialBaiduAdapter * selfBaiduAdapter;
}
@property(nonatomic,retain)BaiduMobAdInterstitial *baiduInterstitial;

@end
