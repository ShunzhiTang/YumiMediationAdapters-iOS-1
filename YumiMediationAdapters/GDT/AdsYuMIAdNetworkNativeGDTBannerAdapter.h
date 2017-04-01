//
//  AdsYuMIAdNetworkNativeGDTAdapter.h
//  AdsYUMISample
//
//  Created by Liubin on 16/4/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "GDTNativeAd.h"
#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
@interface AdsYuMIAdNetworkNativeGDTBannerAdapter : AdsYuMIAdNetworkAdapter <GDTNativeAdDelegate> {
    NSTimer *timer;
    BOOL isReading;
}

@end
