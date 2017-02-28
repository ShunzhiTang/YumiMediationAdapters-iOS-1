//
//  AdsYuMIAdNetworkInterstitialChartboostAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/28.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <Chartboost/Chartboost.h>

@interface AdsYuMIAdNetworkInterstitialChartboostAdapter : AdsYuMIAdNetworkAdapter <ChartboostDelegate>
{
    NSTimer * timer;
    BOOL isReading;
}
@end
