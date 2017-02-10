//
//  AdsYuMIAdNetworkNativeInMobiInterstitialAdapter.h
//  AdsYUMISample
//
//  Created by Liubin on 16/4/20.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIKit/AdsYuMIAdNetworkAdapter.h>

@interface AdsYuMIAdNetworkNativeInMobiInterstitialAdapter : AdsYuMIAdNetworkAdapter
{
  NSTimer * timer;
  BOOL  isReading;
}

@end
