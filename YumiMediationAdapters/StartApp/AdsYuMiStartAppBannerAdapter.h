//
//  AdsYuMiStartAppBannerAdapter.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import <StartApp/StartApp.h>
#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMiStartAppBannerAdapter : AdsYuMIAdNetworkAdapter <STABannerDelegateProtocol> {
    NSTimer *timer;
    BOOL isReading;
    BOOL isStop;
    STABannerView *bannerView;
}

@end
