//
//  AdsYuMIAdNetworkInMobiAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/20.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInMobiAdapter : AdsYuMIAdNetworkAdapter <IMBannerDelegate> {
    BOOL isStop;
    NSTimer *timer;
    BOOL isReading;
    IMBanner *_adview;
}

@end
