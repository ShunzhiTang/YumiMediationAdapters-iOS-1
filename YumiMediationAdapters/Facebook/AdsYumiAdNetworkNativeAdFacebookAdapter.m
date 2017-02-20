//
//  AdsYumiAdNetworkNativeAdFacebookAdapter.m
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/15.
//
//
//按比例适配代码
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
//根据 iPhone6 尺寸进行适配
#define AutoSizeScaleX ScreenWidth/375.f
#define AutoSizeScaleY ScreenHeight/667.f

CG_INLINE CGRect
CGRectMake1(CGFloat x,CGFloat y,CGFloat width,CGFloat height){
    
    CGRect rect;
    rect.origin.x = x*AutoSizeScaleX;
    rect.origin.y = y*AutoSizeScaleY;
    rect.size.width = width *AutoSizeScaleX;
    rect.size.height = height*AutoSizeScaleY;
    return rect;
}

#import "AdsYumiAdNetworkNativeAdFacebookAdapter.h"

@implementation AdsYumiAdNetworkNativeAdFacebookAdapter

+ (NSString*)networkType{
    return AdsYuMIAdNetworkAdFacebook;
}

+ (void)load {
    [[AdsYuMIBannerSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}

-(void)getAd{
    
    isReading=NO;
    FBAdSize adSize =  kFBAdSize320x50;
    switch (self.adType) {
        case AdViewYMTypeNormalBanner:
        case AdViewYMTypeiPadNormalBanner:
            adSize = kFBAdSizeHeight50Banner;
            break;
        case AdViewYMTypeRectangle:
            adSize = kFBAdSizeHeight250Rectangle;
            break;
        case AdViewYMTypeMediumBanner:
            adSize = kFBAdSizeInterstitial;
            break;
        case AdViewYMTypeLargeBanner:
            adSize = kFBAdSizeHeight90Banner;
            break;
        default:
            [self adapter:self didFailAd:nil];
            break;
    }
    
    if (self.IsAutoAdSize) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            adSize = kFBAdSizeHeight90Banner;
        }else {
            adSize = kFBAdSizeHeight50Banner;
        }
    }
    
    [self adDidStartRequestAd];
    
    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(timeOutTimer) userInfo:nil repeats:NO];
    }
    else{
        timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(timeOutTimer) userInfo:nil repeats:NO];
    }
    
    //竖屏
    [self createBannerView];
    
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.key1];
    nativeAd.delegate = self;
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [nativeAd loadAd];
    
    self.adNetworkView = self.AdUIView;
  
}

-(void)createBannerView{
    float h;
    float w = [UIScreen mainScreen].bounds.size.width;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        float proportion = 90.0f/728.0f;
        h = w * proportion;
    }else{
        float proportion = 50.0f/320.0f;
        h = w * proportion;
    }

    self.AdUIView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    //小图
    float space = (h-50)/2;
    self.adIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake1(space, space, 50, 50)];
    
    //tittle
    self.adTitleLable = [[UILabel alloc]initWithFrame:CGRectMake1(space*2+50, space, 180, 30)];
    
    //adSocialContext
    self.adSocialContext = [[UILabel alloc]initWithFrame:CGRectMake1(space*2+50, space*2+20, 180, 10)];
    
    //button
    self.adCallToActionaButton = [[UIButton alloc]initWithFrame:CGRectMake1(space*3+50+180, (h-30)/2, 90, 30)];
    self.adCallToActionaButton.backgroundColor = [UIColor colorWithRed:74/255.0 green:123/255.0 blue:251/255.0 alpha:1.0];
    
    //backgroundView
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake((w-(space+self.adCallToActionaButton.frame.origin.x+self.adCallToActionaButton.frame.size.width))/2, 0, space+self.adCallToActionaButton.frame.origin.x+self.adCallToActionaButton.frame.size.width, h)];
    [backgroundView addSubview:self.adIconImageView];
    [backgroundView addSubview:self.adTitleLable];
    [backgroundView addSubview:self.adSocialContext];
    [backgroundView addSubview:self.adCallToActionaButton];
    [self.AdUIView addSubview:backgroundView];
}
-(void)stopAd {
    isStop = YES;
    [self stopTimer];
}

-(void)timeOutTimer{
    
    if (isStop || isReading) {
        return;
    }
    isReading =YES;
    
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Facebook time out"]];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark FBNativeAdDelegate 

/**
 Sent when an FBNativeAd has been successfully loaded.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd{
    if (isStop) {
        return;
    }    
    if (isReading) {
        return;
    }
    isReading=YES;

    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }
    
    self.nativeAd = nativeAd;
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self.AdUIView
                      withViewController:[self viewControllerForPresentModalView]];
    
    __weak typeof(self) weakSelf = self;
    [self.nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.adIconImageView.image = image;
        [self stopTimer];
        [self adapter:self didReceiveAdView:self.adNetworkView];
    }];
    
    // Render native ads onto UIView
    self.adTitleLable.text = self.nativeAd.title;
    self.adSocialContext.text = self.nativeAd.socialContext;
    [self.adCallToActionaButton setTitle:self.nativeAd.callToAction
                               forState:UIControlStateNormal];
    
}

/**
 Sent immediately before the impression of an FBNativeAd object will be logged.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd{
    
}

/**
 Sent when an FBNativeAd is failed to load.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error{
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading=YES;
    [self stopTimer];
    [self adapter:self didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Facebook no ad"]];
}

/**
 Sent after an ad has been clicked by the person.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidClick:(FBNativeAd *)nativeAd{
     [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

/**
 When an ad is clicked, the modal view will be presented. And when the user finishes the
 interaction with the modal view and dismiss it, this message will be sent, returning control
 to the application.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    
}

- (void)dealloc {
    if (self.adNetworkView) {
        self.AdUIView = nil;
        self.adTitleLable = nil;
        self.adSocialContext = nil;
        self.adCallToActionaButton = nil;
        self.nativeAd.delegate = nil;
        self.nativeAd = nil;
}
}

@end
