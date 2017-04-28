//
//  AdsYuMIAdNetworkNativeGDTAdapter.m
//  AdsYUMISample
//
//  Created by Liubin on 16/4/15.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkNativeGDTBannerAdapter.h"
//#import <YumiMediationSDK/YumiTemplateTool.h>

@interface AdsYuMIAdNetworkNativeGDTBannerAdapter () <UIWebViewDelegate> {

    GDTNativeAd *_nativeAd;      //原生广告实例
    NSArray *_data;              //原生干告数据数组
    GDTNativeAdData *_currentAd; //当前展示的原生干告数据对象
    UIWebView *_webView;
}
//@property (nonatomic, strong) YumiTemplateTool *templateTool;
@property (nonatomic, strong) NSDictionary *templateDic;
@property (nonatomic, assign) NSInteger currentID;
@end

@implementation AdsYuMIAdNetworkNativeGDTBannerAdapter

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdGDTNative;
}

+ (void)load {
    [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {

    isReading = NO;
    [self adDidStartRequestAd];

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
    /*
     * 创建原生干告 *
     * 本原生干告位ID在联盟系统中创建时勾选的详情图尺寸为1280*720,开发者可以根据自己应
     用的需要
     * 创建对应的尺寸规格ID *
     * 这里详情图以1280*720为例 */
    CGSize size = CGSizeZero;
    switch (self.adType) {
        case AdViewYMTypeUnknown:
        case AdViewYMTypeNormalBanner:
            size = CGSizeMake(320, 50);
            break;
        case AdViewYMTypeMediumBanner:
            size = CGSizeMake(468, 60);
            break;
        case AdViewYMTypeiPadNormalBanner:
        case AdViewYMTypeLargeBanner:
            size = CGSizeMake(728, 90);
            break;
        default:
            [self adapter:self
                didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd
                                          description:@"gdt native adtype does not exist"]];
            return;
    }

    if (self.IsAutoAdSize) {
        size = [self getAutoAdSize];
    }

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        _webView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;

    _nativeAd = [[GDTNativeAd alloc] initWithAppkey:self.provider.key1 placementId:self.provider.key2];
    _nativeAd.controller = [self viewControllerForPresentModalView];
    _nativeAd.delegate = self;
    [_nativeAd loadAd:1];
}

#pragma mark -GDT回调
- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {

    if (isReading) {
        return;
    }
    [self stopTimer];
    isReading = YES;

    if (!nativeAdDataArray || ![nativeAdDataArray objectAtIndex:0]) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }
    /*干告数据拉取成功,存储并展示*/
    _data = nativeAdDataArray;

#if __has_feature(objc_arc)

#else
    [_data retain];
#endif
    _currentAd = [_data objectAtIndex:0];

    if (![_currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl] ||
        ![_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc]) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }

    NSString *path = [self resourceNamedFromCustomBundle:@"native-banner"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    str = [NSString stringWithFormat:str, @"100%", @"100%", @"50%", @"100%", @"100%", @"100%", @"100%", @"跳转",
                                     [_currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl],
                                     [_currentAd.properties objectForKey:GDTNativeAdDataKeyTitle],
                                     [_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc], @"%"];

    if ([self isNull:str]) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
        return;
    }

    [_webView loadHTMLString:str baseURL:nil];
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
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

- (void)stopAd {
    [self stopTimer];
}

- (void)timeOutTimer {
    if (isReading) {
        return;
    }
    [self stopTimer];
    isReading = YES;
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"GDT no ad"]];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
#pragma mark--广告webView回调
- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType {
    // TODO: 判断点击类型
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [_nativeAd clickAd:_currentAd]; /*点击发生,调用点击接口*/
        [self adapter:self didClickAdView:_webView WithRect:CGRectZero];
        return NO;
    }
    return YES;
}

/**
 *  UIWebView加载完毕的时候调用(请求完毕)
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_nativeAd attachAd:_currentAd toView:webView];
    [self adapter:self didReceiveAdView:_webView];
}

/**
 *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
 */
- (void)nativeAdWillPresentScreen {

    [self pauseAdapter:self];
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

    [self continueAdapter:self];
}

- (void)dealloc {
    if (_webView) {
        [_webView loadHTMLString:@"" baseURL:nil];
        _webView.delegate = nil;
        _webView = nil;
    }
#if __has_feature(objc_arc)

#else
    [_data release];
    _data = nil;
#endif
}

@end
