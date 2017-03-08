//
//  YuMIVideoAdAdcolonyNetworkAdapter.m
//  YUMIVideoSample
//
//  Created by wxl on 15/9/21.
//  Copyright (c) 2015年 AdsYuMI. All rights reserved.
//

#import "YuMIVideoAdAdcolonyNetworkAdapter.h"

#define kAdColonyAppID @"appbdee68ae27024084bb334a"
#define kAdColonyZoneID @"vzf8e4e97704c4445c87504e"

@implementation YuMIVideoAdAdcolonyNetworkAdapter

+ (NSString *)networkType {
    return YuMIVideoAdNetworkAdAdcolony;
}

+ (void)load {
    [[YuMIVideoSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)initplatform {

    [AdColony configureWithAppID:self.provider.key1 zoneIDs:@[ self.provider.key2 ] delegate:self logging:YES];
}

- (BOOL)isAvailableVideo {
    return [AdColony isVirtualCurrencyRewardAvailableForZone:self.provider.key2];
}

- (void)playVideo {
    [self adapterStartPlayVideo:self];
    [AdColony playVideoAdForZone:self.provider.key2 withDelegate:self withV4VCPrePopup:NO andV4VCPostPopup:NO];
}

#pragma mark -
#pragma mark AdColony V4VC
// 奖励回调接口
// this method give a reward
- (void)onAdColonyV4VCReward:(BOOL)success
                currencyName:(NSString *)currencyName
              currencyAmount:(int)amount
                      inZone:(NSString *)zoneID {
    [self adapterPlayToComplete:self];
}

#pragma mark -
#pragma mark AdColony ad fill
// 时时检测广告状态
// this method open a timer to check out ad status
- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID {
}

// 关闭视频广告按钮
// this method shut down the video ad
- (void)onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info {
    [self adapterdidCompleteVideo:self];
    [self adapter:self rewards:1];
}

@end
