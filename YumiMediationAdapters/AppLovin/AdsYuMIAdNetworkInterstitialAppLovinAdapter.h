//
//  AdsYuMIAdNetworkInterstitialAppLovinAdapter.h
//  AdsYUMISample
//
//  Created by wxl on 15/11/5.
//  Copyright © 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>

//问题1：key不能通过后台设置，只能在plist里面设置
//问题2：插屏和视频分不开
//问题3：将该平台的视频加到聚合视频中

@interface AdsYuMIAdNetworkInterstitialAppLovinAdapter : AdsYuMIAdNetworkAdapter {
    NSTimer *timer;
    BOOL isReading;
}
@end
