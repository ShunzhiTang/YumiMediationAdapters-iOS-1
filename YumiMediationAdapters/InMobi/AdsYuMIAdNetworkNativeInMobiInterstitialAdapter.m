//
//  AdsYuMIAdNetworkNativeInMobiInterstitialAdapter.m
//  AdsYUMISample
//
//  Created by Liubin on 16/4/20.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkNativeInMobiInterstitialAdapter.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/AdsYuMiInterstitialNativeViewController.h>
#import <YumiMediationSDK/YumiTemplateTool.h>

@interface AdsYuMIAdNetworkNativeInMobiInterstitialAdapter () <AdsYuMiInterstitialNativeViewControllerDelegate,
                                                               IMNativeDelegate> {
    AdsYuMIAdNetworkNativeInMobiInterstitialAdapter *_adsYuMIInMobiSelf;
    AdsYuMiInterstitialNativeViewController *_gdtInterstitialWebView;
    IMNative *imnative;
    NSDictionary *imobeDict;
    BOOL loadSuccessed;
}
@property (nonatomic, strong) YumiTemplateTool *templateTool;
@property (nonatomic, strong) NSDictionary *templateDic;
@property (nonatomic, assign) NSInteger currentID;
@end

@implementation AdsYuMIAdNetworkNativeInMobiInterstitialAdapter
+ (NSString *)networkType {
    //  return @"123";
    return AdsYuMIAdNetworkAdInMobiNative;
}

+ (void)load {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
    }
}

- (void)getRemoteTemplate{
    self.templateTool = [[YumiTemplateTool alloc]init];
    NSString *fileName = [NSString stringWithFormat:@"inter%@",self.provider.providerId];
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
            [self.templateTool getYumiTemplateWith:self.provider.uniTemplateID Id2:self.provider.lanTemplateID Id3:self.provider.porTemplateID Providerid:fileName];
        }
    }else{
        [self.templateTool getYumiTemplateWith:self.provider.uniTemplateID Id2:self.provider.lanTemplateID Id3:self.provider.porTemplateID Providerid:fileName];
    }
}

- (void)getAd {
    [self adapterDidStartInterstitialRequestAd];
    isReading = NO;
    loadSuccessed = NO;
    
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

    [IMSdk initWithAccountID:self.provider.key1];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    imnative = [[IMNative alloc] initWithPlacementId:[self.provider.key2 longLongValue]];
    imnative.delegate = self;
    [imnative load];
    _adsYuMIInMobiSelf = self;
}

//是否自动发送统计
- (BOOL)isAutoStatistical {
    return NO;
}

#pragma mark - IMOBI回调
- (void)nativeDidFinishLoading:(IMNative *)native {
    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];

    if (!native || !native.adContent) {
        [self adapter:self
            didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    imobeDict = [self dictionaryWithJsonString:native.adContent];
#if __has_feature(objc_arc)

#else
    [imobeDict retain];
#endif

    if (imobeDict == nil || ![imobeDict objectForKey:@"screenshots"]) {
        [_adsYuMIInMobiSelf adapter:self
              didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    NSUInteger width = [[[imobeDict objectForKey:@"screenshots"] objectForKey:@"width"] integerValue];
    NSUInteger height = [[[imobeDict objectForKey:@"screenshots"] objectForKey:@"height"] integerValue];
    NSString *url = [[imobeDict objectForKey:@"screenshots"] objectForKey:@"url"];

    if (!url || url.length == 0 || width == 0 || height == 0) {
        [_adsYuMIInMobiSelf adapter:self
              didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    _gdtInterstitialWebView =
        [[AdsYuMiInterstitialNativeViewController alloc] initWithCustomView:CGRectMake(0, 0, width, height)
                                                                   delegate:self];

    NSString *interstitialPath = [self resourceNamedFromCustomBundle:@"cp-img"];
    NSData *interstitialData = [NSData dataWithContentsOfFile:interstitialPath];
    NSString *interstitialStr = [[NSString alloc] initWithData:interstitialData encoding:NSUTF8StringEncoding];
    interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"100%", @"100%",
                                                 [imobeDict objectForKey:@"landingURL"], url];
    
    if (self.templateDic) {
        NSString *templateID = self.templateDic[@"templateID"];
        NSString *currentID = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.currentID]];
        if (![templateID isEqualToString:currentID]) {
            return;
        }
        interstitialStr = self.templateDic[@"html"];
        interstitialStr = [self.templateTool replaceHtmlCharactersWith:interstitialStr Zflag_iconUrl:@"" Zflag_title:@"" Zflag_desc:@"" Zflag_imageUrl:url Zflag_aTagUrl:[imobeDict objectForKey:@"landingURL"]];
    }

    if ([self isNull:interstitialStr]) {
        [self adapter:self
            didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }
    // TODO:物料加载成功...
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

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic =
        [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        //    NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];

    [_adsYuMIInMobiSelf adapter:self
          didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
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

/**
 *  平台超时
 */
- (void)timeOutTimer {
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [_adsYuMIInMobiSelf adapter:self
          didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Inmobi time out"]];
}
/**
 *  插屏展示
 */
- (void)preasentInterstitial {
    [_gdtInterstitialWebView presentInterView:[self viewControllerForWillPresentInterstitialModalView]];
    // inmobi展示
    [IMNative bindNative:imnative toView:_gdtInterstitialWebView.interstiwebView];
    [_adsYuMIInMobiSelf adapterInterstitialDidPresentScreen:self];
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
    [self stopTimer];
    [_adsYuMIInMobiSelf adapter:self
          didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
}

// TODO:广告加载完成
- (void)adInterstitialViewDidFinsh {
    if (loadSuccessed) {
        return;
    }
    loadSuccessed = YES;
    [_adsYuMIInMobiSelf adapterDidInterstitialReceiveAd:self];
}
// TODO:广告点击事件
- (void)adInterstitialViewClick {
    // inmobi点击
    [imnative reportAdClick:imobeDict];
    [self adViewClick];
    [_adsYuMIInMobiSelf adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

// TODO:点击关闭按钮关闭广告
- (void)adInterstitialViewClickCloseBtn {
    [_adsYuMIInMobiSelf adapterInterstitialDidDismissScreen:self];
}

//点击广告
- (void)adViewClick {
    //  NSLog(@"%@",[imobeDict objectForKey:@"landingURL"]);
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[imobeDict objectForKey:@"landingURL"]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[imobeDict objectForKey:@"landingURL"]]];
    }
}

- (void)dealloc {
#if __has_feature(objc_arc)
#else

    if (imobeDict) {
        [imobeDict release];
        imobeDict = nil;
    }
#endif

    if (_gdtInterstitialWebView) {
        _gdtInterstitialWebView.delegate = nil;
        _gdtInterstitialWebView = nil;
    }
}

@end
