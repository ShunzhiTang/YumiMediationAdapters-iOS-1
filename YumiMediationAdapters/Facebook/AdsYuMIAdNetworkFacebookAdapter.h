//
//  AdsYuMIAdNetworkFacebookAdapter.h
//  AdsYUMISample
//
//  Created by xinglei on 15/8/21.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <FBAudienceNetwork/FBAdView.h>

@interface AdsYuMIAdNetworkFacebookAdapter : AdsYuMIAdNetworkAdapter <FBAdViewDelegate>
{
  BOOL isStop;
  NSTimer *timer;
  BOOL isReading;
}

@property (nonatomic, strong) FBAdView *fbView;

@end
