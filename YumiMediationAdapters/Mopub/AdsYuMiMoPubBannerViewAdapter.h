//
//  AdsYuMiMoPubBannerViewAdapter.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import "MPAdView.h"

@interface AdsYuMiMoPubBannerViewAdapter : AdsYuMIAdNetworkAdapter<MPAdViewDelegate>{
  NSTimer * timer;
  BOOL isReading;
  BOOL isStop;
  MPAdView *MPView;
}

@end
