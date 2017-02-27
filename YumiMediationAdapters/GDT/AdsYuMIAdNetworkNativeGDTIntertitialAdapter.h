//
//  AdsYuMIAdNetworkNativeGDTIntertitialAdapter.h
//  AdsYUMISample
//
//  Created by Liubin on 16/4/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdapter.h"
#import "GDTNativeAd.h"

@interface AdsYuMIAdNetworkNativeGDTIntertitialAdapter : AdsYuMIAdNetworkAdapter
{
  NSTimer * timer;
  BOOL  isReading;
}

@end
