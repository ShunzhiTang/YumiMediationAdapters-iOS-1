//
//  AdsYuMIAdNetworkInterstitialUnityAdapter.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 2017/2/6.
//  Copyright © 2017年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkAdapter.h"
#import <UnityAds/UnityAds.h>

@interface AdsYuMIAdNetworkInterstitialUnityAdapter : AdsYuMIAdNetworkAdapter<UnityAdsDelegate>
{
  NSTimer * timer;
  BOOL isReading;
}
@end
