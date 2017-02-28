//
//  AdsYuMIAdNetworkGDTAdapter.h
//  AdsYUMISample
//
//  Created by Castiel Chen on 15/8/18.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import "GDTMobBannerView.h"
@interface AdsYuMIAdNetworkGDTAdapter : AdsYuMIAdNetworkAdapter<GDTMobBannerViewDelegate>
{
    NSTimer * timer;
    BOOL isReading;
  
}
@property(strong,nonatomic)GDTMobBannerView* gdtAdView;
@end
