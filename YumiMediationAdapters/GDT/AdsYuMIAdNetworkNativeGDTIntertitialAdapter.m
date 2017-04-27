//
//  AdsYuMIAdNetworkNativeGDTIntertitialAdapter.m
//  AdsYUMISample
//
//  Created by Liubin on 16/4/18.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkNativeGDTIntertitialAdapter.h"
#import <YumiMediationSDK/AdsYuMiInterstitialNativeViewController.h>
#import <YumiMediationSDK/YumiTemplateTool.h>

@interface AdsYuMIAdNetworkNativeGDTIntertitialAdapter () <GDTNativeAdDelegate,
                                                           AdsYuMiInterstitialNativeViewControllerDelegate> {

    AdsYuMIAdNetworkNativeGDTIntertitialAdapter *_adsYuMIGDTSelf;
    GDTNativeAd *_nativeAd;      //原生干告实例
    NSArray *_data;              //原生干告数据数组
    GDTNativeAdData *_currentAd; //当前展示的原生干告数据对象
    AdsYuMiInterstitialNativeViewController *_gdtInterstitialWebView;

    BOOL loadSuccessed;
    BOOL canShow;
}
@property (nonatomic, strong) YumiTemplateTool *templateTool;
@property (nonatomic, strong) NSDictionary *templateDic;
@property (nonatomic, assign) NSInteger currentID;
@end

@implementation AdsYuMIAdNetworkNativeGDTIntertitialAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdGDTNative;
}

+ (void)load {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
    }
}

- (void)getRemoteTemplate {
    self.templateTool = [[YumiTemplateTool alloc] init];
    NSString *fileName = [NSString stringWithFormat:@"inter%@", self.provider.providerId];
    NSInteger currentTime;
    NSInteger currentMode;
    if ([self.templateTool getOrientation] == 0) {
        self.currentID = self.provider.porTemplateID;
        currentTime = self.provider.porTemplateTime;
        currentMode = self.provider.porMode;
    }
    if ([self.templateTool getOrientation] == 1) {
        self.currentID = self.provider.lanTemplateID;
        currentTime = self.provider.lanTemplateTime;
        currentMode = self.provider.lanMode;
    }
    if (self.provider.uniTemplateID) {
        self.currentID = self.provider.uniTemplateID;
        currentTime = self.provider.uniTemplateTime;
        currentMode = self.provider.uniMode;
    }
    if ([self.templateTool isExistWith:currentTime TemplateID:self.currentID ProviderID:fileName]) {
        self.templateDic = [self.templateTool getTemplateHtmlWith:self.currentID];
        if (self.templateDic == nil) {
            [self.templateTool getYumiTemplateWith:self.provider.uniTemplateID
                                               Id2:self.provider.lanTemplateID
                                               Id3:self.provider.porTemplateID
                                        Providerid:fileName];
        }
    } else {
        [self.templateTool getYumiTemplateWith:self.provider.uniTemplateID
                                           Id2:self.provider.lanTemplateID
                                           Id3:self.provider.porTemplateID
                                    Providerid:fileName];
    }
}

- (void)getAd {

    loadSuccessed = NO;
    canShow = NO;
    isReading = NO;

    [self adapterDidStartInterstitialRequestAd];

    [self getRemoteTemplate];

    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }
    _gdtInterstitialWebView =
        [[AdsYuMiInterstitialNativeViewController alloc] initWithCustomView:[UIScreen mainScreen].bounds
                                                                   delegate:self
                                                                   isBorder:NO];
    _nativeAd = [[GDTNativeAd alloc] initWithAppkey:self.provider.key1 placementId:self.provider.key2];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        _nativeAd.controller = [self viewControllerForWillPresentInterstitialModalView];
    } else {
        _nativeAd.controller = _gdtInterstitialWebView;
    }
    _nativeAd.delegate = self;
    [_nativeAd loadAd:1];
    _adsYuMIGDTSelf = self;
}

#pragma mark - GDT回调
- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {

    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];

    if (!nativeAdDataArray || ![nativeAdDataArray objectAtIndex:0]) {
        [self adapter:self
            didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }

    /*干告数据拉取成功,存储并展示*/
    _data = nativeAdDataArray;

#if __has_feature(objc_arc)

#else
    [_data retain];
#endif
    _currentAd = [_data objectAtIndex:0];

    if (!_currentAd.properties || ![_currentAd.properties objectForKey:GDTNativeAdDataKeyImgUrl] ||
        ![_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc]) {
        [self adapter:self
            didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }

    NSString *bigImg = [_currentAd.properties objectForKey:GDTNativeAdDataKeyImgUrl];
    NSString *iconImg = [_currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl];
    NSString *title = [_currentAd.properties objectForKey:GDTNativeAdDataKeyTitle];
    NSString *desc = [_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc];
    NSString *star = [[_currentAd.properties objectForKey:GDTNativeAdDataKeyAppRating] stringValue];
    //  NSString *price = [[_currentAd.properties objectForKey:GDTNativeAdDataKeyAppPrice] stringValue];
    if ([star isEqualToString:@""] || !star) {
        star = @"3.5";
    }

    NSString *interstitialPath;
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ||
        [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        interstitialPath = [self resourceNamedFromCustomBundle:@"cp-native"];
    } else {
        interstitialPath = [self resourceNamedFromCustomBundle:@"cp-native-lan"];
    }

    NSData *interstitialData = [NSData dataWithContentsOfFile:interstitialPath];
    NSString *interstitialStr = [[NSString alloc] initWithData:interstitialData encoding:NSUTF8StringEncoding];

    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ||
        [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"100%", @"100%", @"100%",
                                                     @"70%", @"100%", @"100%", @"100%", @"50%", bigImg, @"100%",
                                                     iconImg, title, desc, star, @"about:blank"];
    } else {
        interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"50%", @"100%", @"100%",
                                                     @"20%", @"2%", @"74%", @"100%", @"100%", @"65%", @"5%", @"30%",
                                                     iconImg, title, star, bigImg, @"100%", desc, @"about:blank"];
    }

    if (self.templateDic) {
        NSString *templateID = self.templateDic[@"templateID"];
        NSString *currentID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:self.currentID]];
        if (![templateID isEqualToString:currentID]) {
            return;
        }
        interstitialStr = self.templateDic[@"html"];
        interstitialStr = [self.templateTool replaceHtmlCharactersWith:interstitialStr
                                                         Zflag_iconUrl:iconImg
                                                           Zflag_title:title
                                                            Zflag_desc:desc
                                                        Zflag_imageUrl:bigImg
                                                         Zflag_aTagUrl:@"跳转"];
    }

    if ([self isNull:interstitialStr]) {
        [self adapter:self
            didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }
    // TODO:预加载成功上报统计
    [self adapterPreloadInterstitialReceiveAd:self];

    [_gdtInterstitialWebView loadHTMLString:interstitialStr];
}

//获取模板路径
- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"YumiMediationSDK" withExtension:@"bundle"];
    NSBundle *YumiMediationSDK = [NSBundle bundleWithURL:bundleURL];

    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];
    return strPath;
}

/**
 *  原生广告加载广告数据失败回调
 */
- (void)nativeAdFailToLoad:(NSError *)error {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];

    [_adsYuMIGDTSelf adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

/**
 *  停止展示广告
 */
- (void)stopAd {
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

//是否自动发送统计
- (BOOL)isAutoStatistical {
    return NO;
}

/**
 *  平台超时
 */
- (void)timeOutTimer {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [_adsYuMIGDTSelf adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"GDT time out"]];
}
/**
 *  插屏展示
 */
- (void)preasentInterstitial {
    if (!canShow) {
        return;
    }
    [_gdtInterstitialWebView presentInterView:[self viewControllerForWillPresentInterstitialModalView]];
    //调用广点通展示完成
    [_nativeAd attachAd:_currentAd toView:_gdtInterstitialWebView.interstiwebView];
    [_adsYuMIGDTSelf adapterInterstitialDidPresentScreen:self];
}

// TODO:广开始加载
- (void)adInterstitialViewDidStart {
}
// TODO:广告加载失败
- (void)adInterstitialViewDidFail:(NSError *)error {
    if (loadSuccessed) {
        return;
    }
    loadSuccessed = YES;
    canShow = NO;
    [self stopTimer];
    [_adsYuMIGDTSelf adapter:self
        didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

// TODO:广告加载完成
- (void)adInterstitialViewDidFinsh {
    if (loadSuccessed) {
        return;
    }
    canShow = YES;
    loadSuccessed = YES;
    [_adsYuMIGDTSelf adapterDidInterstitialReceiveAd:self InterTemplateID:self.currentID];
}
// TODO:广告点击事件
- (void)adInterstitialViewClick {
    [_nativeAd clickAd:_currentAd]; /*点击发生,调用点击接口*/
    [_adsYuMIGDTSelf adapterDidInterstitialClick:self ClickArea:CGRectZero InterTemplateID:self.currentID];
}

- (void)nativeClick {
    [_nativeAd clickAd:_currentAd]; /*点击发生,调用点击接口*/
    [_adsYuMIGDTSelf adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

// TODO:点击关闭按钮关闭广告
- (void)adInterstitialViewClickCloseBtn {
    [_adsYuMIGDTSelf adapterInterstitialDidDismissScreen:self];
}

/**
 *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
 */
- (void)nativeAdWillPresentScreen {

    //   [self pauseAdapter:self];
}

/**
 *  原生广告点击之后应用进入后台时回调
 */
- (void)nativeAdApplicationWillEnterBackground {
}

/**
 * 原生广告点击以后，内置AppStore或是内置浏览器被关闭时回调
 */
- (void)nativeAdClosed {

    //  [self continueAdapter:self];
}

- (void)dealloc {
    if (_nativeAd) {
        _nativeAd.delegate = nil;
        _nativeAd = nil;
    }
    if (_gdtInterstitialWebView) {
        _gdtInterstitialWebView.delegate = nil;
        _gdtInterstitialWebView = nil;
    }
#if __has_feature(objc_arc)

#else
    [_data release];
    _data = nil;
#endif
}

@end
