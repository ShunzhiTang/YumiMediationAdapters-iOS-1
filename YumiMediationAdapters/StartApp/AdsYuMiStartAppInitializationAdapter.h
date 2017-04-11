//
//  AdsYuMiStartAppInitializationAdapter.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import <StartApp/StartApp.h>
#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMiStartAppInitializationAdapter : AdsYuMIAdNetworkAdapter <STADelegateProtocol> {
    STAStartAppAd *startAppAd;
    NSTimer *timer;
    BOOL isReading;
    BOOL isClick;
}

@end
