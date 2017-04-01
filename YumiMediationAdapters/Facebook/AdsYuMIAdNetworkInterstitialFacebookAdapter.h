//
//  AdsYuMIAdNetworkInterstitialFacebookAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/25.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <FBAudienceNetwork/FBInterstitialAd.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkInterstitialFacebookAdapter : AdsYuMIAdNetworkAdapter <FBInterstitialAdDelegate> {
    NSTimer *timer;
    BOOL isReading;
}

@property (nonatomic, retain) FBInterstitialAd *interstitial;

@end
