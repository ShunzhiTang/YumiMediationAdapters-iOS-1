//
//  AdsYuMIAdNetworkInterstitialGoogleAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdsYuMIAdNetworkInterstitialGoogleAdapter : AdsYuMIAdNetworkAdapter <GADInterstitialDelegate> {
    NSTimer *timer;
    BOOL isReading;
}
@property (nonatomic, retain) GADInterstitial *interstitial;

@end
