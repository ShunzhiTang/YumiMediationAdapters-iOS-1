//
//  ViewController.m
//  YUMISample
//
//  Created by xinglei on 15/9/29.
//  Copyright © 2015年 Zplay. All rights reserved.
//

#import "YumiMediationViewController.h"
#import <YumiMediationSDK/AdsYuMIView.h>
#import <YumiMediationSDK/YuMIInterstitial.h>
#import <YumiMediationSDK/YuMIInterstitialManager.h>
//#import "AdsYUMILogCenter.h"
//#import <YuMIDebugCenter/YuMIDebugCenter.h>
//#import "AdsYuMIDeviceInfo.h"

#define YUMIBANNER_ID       @"3f521f0914fdf691bd23bf85a8fd3c3a"
#define YUMIINTERSTITIAL_ID @"3f521f0914fdf691bd23bf85a8fd3c3a"
#define YUMI_CHANNELID      @""
#define YUMI_VERSIONID      @""

@interface YumiMediationViewController ()<AdsYuMIDelegate,YuMIInterstitialDelegate>
{
    AdsYuMIView * adView;
    YuMIInterstitial * inter;

}

@end

@implementation YumiMediationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



#pragma mark - YUMIBanner delegate
/**
 * 返回展示当前横幅的视图
 */
- (UIViewController *)viewControllerForPresentingYUMIModalView {
    return self;
}

/**
 * 广告开始请求回调
 */
- (void)adsYuMIDidStartAd:(AdsYuMIView *)adView{
    NSLog(@"%s",__FUNCTION__);
}
/**
 * You can get notified when the user receive the ad
 广告接收成功回调
 */
- (void)adsYuMIDidReceiveAd:(AdsYuMIView *)adView{
    NSLog(@"%s",__FUNCTION__);
}
/**
 * You can get notified when the user failed receive the ad
 广告接收失败回调
 */
- (void)adsYuMIDidFailToReceiveAd:(AdsYuMIView *)adView didFailWithError:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
}
/**
 * 点击广告回调
 */
- (void)adsYuMIClickAd:(AdsYuMIView *)adView{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark -
#pragma mark - 插屏代理方法
/*
 返回广告rootViewController
 */
- (UIViewController *)viewControllerForPresentingInterstitialModalView {
    return self;
}

/**
 *  Description         插屏加载成功
 *
 *  @param ad           返回一个插屏的实例
 */
- (void)YuMIInterstitialDidReceiveAd:(YuMIInterstitial *)ad {
    NSLog(@"%s",__FUNCTION__);
}
/**
 *  Description         插屏加载失败
 *
 *  @param ad           返回一个插屏实例
 *  @param error        返回错误信息
 */
- (void)YuMIInterstitial:(YuMIInterstitial *)ad didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    
}
/**
 *  Description         插屏已经消失
 *
 *  @param ad           返回一个插屏的实例
 */
- (void)YuMIInterstitialDidDismissScreen:(YuMIInterstitial *)ad {
    NSLog(@"%s",__FUNCTION__);
    
}
/**
 *  Description         插屏点击
 *
 */
- (void)adapterDidInterstitialClick{
    
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - YUMIVideo delegate
- (UIViewController *)viewControllerVideoModalView{
    return self;
}

- (void)startRequestVideoAd{
    
}

- (void)didCompleteVideo {
    
}

-(void)rewardsVideo {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
