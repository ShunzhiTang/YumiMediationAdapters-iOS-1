//
//  AdsYuMIAdNetworkAdGoogleAdapter.h
//  AdsYUMISample
//
//  Created by wxl on 15/8/24.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkAdGoogleAdapter : AdsYuMIAdNetworkAdapter <GADBannerViewDelegate> {
    BOOL isStop;
    NSTimer *timer;
    GADBannerView *_bannerView;
    BOOL isReading;
}
@end
