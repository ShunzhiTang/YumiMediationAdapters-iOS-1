//
//  AdsYuMIAdNetworkInterstitialBaiduAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInterstitialBaiduAdapter : AdsYuMIAdNetworkAdapter <BaiduMobAdInterstitialDelegate> {
    NSTimer *timer;
    BOOL isReading;
    AdsYuMIAdNetworkInterstitialBaiduAdapter *selfBaiduAdapter;
}
@property (nonatomic, retain) BaiduMobAdInterstitial *baiduInterstitial;

@end
