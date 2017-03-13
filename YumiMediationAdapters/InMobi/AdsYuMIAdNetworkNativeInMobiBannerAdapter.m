//
//  AdsYuMIAdNetworkNativeInMobiBannerAdapter.m
//  AdsYUMISample
//
//  Created by Liubin on 16/4/19.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMIAdNetworkNativeInMobiBannerAdapter.h"
#import <InMobiSDK/InMobiSDK.h>

@interface AdsYuMIAdNetworkNativeInMobiBannerAdapter () <IMNativeDelegate, UIWebViewDelegate> {
    NSDictionary *imobeDict;
    IMNative *imnative;
    UIWebView *_webView;
}

@end

@implementation AdsYuMIAdNetworkNativeInMobiBannerAdapter
+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdInMobiNative;
}

+ (void)load {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
    }
}

- (void)getAd {
    [self adDidStartRequestAd];
    isReading = NO;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

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
}

#pragma mark -  InMobi 回调
- (void)nativeDidFinishLoading:(IMNative *)native {

    //  NSLog(@"广告物料：%@",imobeDict);

    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];

    if (!native || !native.adContent) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    imobeDict = [self dictionaryWithJsonString:native.adContent];

#if __has_feature(objc_arc)

#else
    [imobeDict retain];
#endif

    if (imobeDict == nil || ![imobeDict objectForKey:@"screenshots"]) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    NSUInteger width = [[[imobeDict objectForKey:@"screenshots"] objectForKey:@"width"] integerValue];
    NSUInteger height = [[[imobeDict objectForKey:@"screenshots"] objectForKey:@"height"] integerValue];

    NSString *url = [[imobeDict objectForKey:@"screenshots"] objectForKey:@"url"];

    if (!url || url.length == 0 || width == 0 || height == 0) {
        [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
        return;
    }

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _webView.scrollView.scrollEnabled = NO;
    _webView.delegate = self;

    NSString *path = [self resourceNamedFromCustomBundle:@"banner-img"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    str = [NSString stringWithFormat:str, @"100%", @"100%", @"100%", @"100%", [imobeDict objectForKey:@"landingURL"],
                                     [[imobeDict objectForKey:@"screenshots"] objectForKey:@"url"]];

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

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic =
        [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
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

    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Inmobi no ad"]];
}

- (void)stopAd {
    [self stopTimer];
}

- (void)timeOutTimer {

    if (isReading) {
        return;
    }
    isReading = YES;

    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Inmobi time out"]];
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
        [imnative reportAdClick:imobeDict];
        [self adapter:self didClickAdView:_webView WithRect:CGRectZero];
        [self adViewClick:request.URL];
        return NO;
    }
    return YES;
}

- (void)adViewClick:(NSURL *)requestURL {
    if ([[UIApplication sharedApplication] canOpenURL:requestURL]) {
        [[UIApplication sharedApplication] openURL:requestURL];
    }
}

/**
 *  UIWebView加载完毕的时候调用(请求完毕)
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [IMNative bindNative:imnative toView:webView];
    [self adapter:self didReceiveAdView:_webView];
}

- (void)dealloc {

#if __has_feature(objc_arc)
#else

    if (imobeDict) {
        [imobeDict release];
        imobeDict = nil;
    }
#endif

    if (_webView) {
        [_webView loadHTMLString:@"" baseURL:nil];
        _webView.delegate = nil;
        _webView = nil;
    }
    imnative = nil;
    imobeDict = nil;
}

@end
