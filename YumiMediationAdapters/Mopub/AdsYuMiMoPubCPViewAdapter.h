//
//  AdsYuMiMoPubCPViewAdapter.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "MPInterstitialAdController.h"
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMiMoPubCPViewAdapter : AdsYuMIAdNetworkAdapter <MPInterstitialAdControllerDelegate> {
    NSTimer *timer;

    BOOL isReading;
    BOOL isClick;

    MPInterstitialAdController *MPCPView;
}

@end
