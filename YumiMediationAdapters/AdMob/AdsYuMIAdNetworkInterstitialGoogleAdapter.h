//
//  AdsYuMIAdNetworkInterstitialGoogleAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInterstitialGoogleAdapter : AdsYuMIAdNetworkAdapter <GADInterstitialDelegate> {
    NSTimer *timer;
    BOOL isReading;
}
@property (nonatomic, retain) GADInterstitial *interstitial;

@end
