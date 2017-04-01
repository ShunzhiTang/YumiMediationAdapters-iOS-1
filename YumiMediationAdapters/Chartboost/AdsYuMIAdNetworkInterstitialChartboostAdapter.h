//
//  AdsYuMIAdNetworkInterstitialChartboostAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/28.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <Chartboost/Chartboost.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInterstitialChartboostAdapter : AdsYuMIAdNetworkAdapter <ChartboostDelegate> {
    NSTimer *timer;
    BOOL isReading;
}
@end
