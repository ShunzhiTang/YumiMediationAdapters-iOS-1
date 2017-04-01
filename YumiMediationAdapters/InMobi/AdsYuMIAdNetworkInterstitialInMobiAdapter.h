//
//  AdsYuMIAdNetworkInterstitialInMobiAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInterstitialInMobiAdapter : AdsYuMIAdNetworkAdapter <IMInterstitialDelegate> {
    NSTimer *timer;
    BOOL isReading;
}
@property (nonatomic, strong) IMInterstitial *interstitialAd;

@end
