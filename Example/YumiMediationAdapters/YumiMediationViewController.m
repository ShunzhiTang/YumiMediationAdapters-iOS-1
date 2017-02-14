//
//  ViewController.m
//  YUMISample
//
//  Created by xinglei on 15/9/29.
//  Copyright © 2015年 Zplay. All rights reserved.
//

#import "YumiMediationViewController.h"
#import <AdsYuMIKit/AdsYuMIView.h>
#import <AdsYuMIKit/YuMIInterstitial.h>
#import <AdsYuMIKit/YuMIInterstitialManager.h>
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
    
    [[AdsYuMILogCenter shareInstance] setLogLeveFlag:9];
    
    [[AdsYuMIDeviceInfo shareDevice] removeTestService];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择服务器" message:nil delegate:self cancelButtonTitle:@"测试服务器" otherButtonTitles:@"正式服务器", nil];
    alert.tag = 112;
    [alert show];
    
}

- (IBAction)showDebug:(id)sender {
    [[YuMIDebugCenter shareInstance] startDebugging:self];
}


- (IBAction)initVideo:(id)sender {
    videoManager=[YMVideoManager startWithYuMIId:YUMIVIDEO_ID channleId:YUMI_CHANNELID versionNumber:YUMI_VERSIONID delegate:self];
    
}

- (IBAction)isExistVideo:(id)sender {
    if ( [[YMVideoManager sharedVideoManager]isReadVideo]) {
        UIAlertView * alertView =[[UIAlertView alloc]initWithTitle:@"提示" message:@"可以播放广告" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        UIAlertView * alertView =[[UIAlertView alloc]initWithTitle:@"提示" message:@"没广告" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (IBAction)playVideo:(id)sender {
    [[YMVideoManager sharedVideoManager]playVideo];
}


//预加载插屏
- (IBAction)clickInterstitialUpload:(id)sender {
    
    inter= [[YuMIInterstitialManager shareInstance]adYuMIInterstitialByAppKey:YUMIINTERSTITIAL_ID channleId:YUMI_CHANNELID versionNumber:YUMI_VERSIONID isStopRotation:NO];
    inter.delegate=self;
    
}

//插屏展示
- (IBAction)clickInterstitialShow:(id)sender {
    if (inter) {
        [inter interstitialShow:NO];
    }
}


- (IBAction)removeBanner:(id)sender {
    if (adView) {
        [adView removeFromSuperview];
    }
}

- (IBAction)createBanner:(id)sender {
    
    float h;
    float w = [UIScreen mainScreen].bounds.size.width;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        float proportion = 90.0f/728.0f;
        h = w * proportion;
    }else{
        float proportion = 50.0f/320.0f;
        h = w * proportion;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        adView =[[AdsYuMIView alloc]initWithAppKey:YUMIBANNER_ID channleId:YUMI_CHANNELID versionNumber:YUMI_VERSIONID AdViewType:AdViewYMTypeLargeBanner StopRotation:NO
                                      isAutoAdSize:YES];
        adView.frame=CGRectMake(0,self.view.frame.size.height-h,0, 0);
    }else {
        adView =[[AdsYuMIView alloc]initWithAppKey:YUMIBANNER_ID channleId:YUMI_CHANNELID versionNumber:YUMI_VERSIONID AdViewType:AdViewYMTypeNormalBanner StopRotation:NO
                                      isAutoAdSize:YES];
        adView.frame=CGRectMake(0,self.view.frame.size.height-h,0, 0);
    }
    adView.delegate=self;
    [self.view addSubview:adView];
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

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[AdsYuMIDeviceInfo shareDevice] openTestService:YES];
            break;
        case 1:
            [[AdsYuMIDeviceInfo shareDevice] openTestService:NO];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
