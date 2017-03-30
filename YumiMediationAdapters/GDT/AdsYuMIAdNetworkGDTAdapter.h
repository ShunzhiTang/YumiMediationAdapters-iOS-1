//
//  AdsYuMIAdNetworkGDTAdapter.h
//  AdsYUMISample
//
//  Created by Castiel Chen on 15/8/18.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "GDTMobBannerView.h"
#import <YumiMediationSDK_Zplay/AdsYuMIAdNetworkAdapter.h>
@interface AdsYuMIAdNetworkGDTAdapter : AdsYuMIAdNetworkAdapter <GDTMobBannerViewDelegate> {
    NSTimer *timer;
    BOOL isReading;
}
@property (strong, nonatomic) GDTMobBannerView *gdtAdView;
@end
