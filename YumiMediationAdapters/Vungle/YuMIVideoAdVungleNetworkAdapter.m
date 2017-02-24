//
//  YuMIVideoAdVungleNetworkAdapter.m
//  YUMIVideoSample
//
//  Created by wxl on 15/9/21.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "YuMIVideoAdVungleNetworkAdapter.h"

@implementation YuMIVideoAdVungleNetworkAdapter

+ (NSString*)networkType{
  return YuMIVideoAdNetworkAdVungle;
}
+ (void)load {
  [[YuMIVideoSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

-(void)initplatform{
  
  [[VungleSDK sharedSDK] startWithAppId:self.provider.key1];
  [[VungleSDK sharedSDK] setDelegate:self];
  [[VungleSDK sharedSDK] setLoggingEnabled:NO];
}


-(BOOL)isAvailableVideo{
  return [[VungleSDK sharedSDK] isAdPlayable];
}



-(void)playVideo{
  [[VungleSDK sharedSDK] playAd:[self viewControllerForPresentingModalView] error:nil];
}

#pragma mark- delegate

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable {
  
}

- (void)vungleSDKwillShowAd{
  
  [self adapterStartPlayVideo:self];
}

//vungle平台并没有提供视频播放完成的回调方法
//退出广告的两种方法，直接关闭广告或者下载新应用
- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
  
  [self adapterPlayToComplete:self];
  [self adapterdidCompleteVideo:self];
  
  if (!viewInfo[@"didDownlaod"]) {
    //vungle视频播放完成关闭
    [self adapter:self rewards:1];
  }else {
    //vungle视频下载新应用关闭
  }
  
}

//此时你可能需要恢复用户使用app的页面。
- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
  
}

- (void)vungleSDKhasCachedAdAvailable __attribute__((deprecated)) {
  
}

@end
