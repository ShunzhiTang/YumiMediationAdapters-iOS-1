//
//  AdsYumiAdNetworkNativeInterFacebookAdapter.m
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/20.
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

#import "AdsYumiAdNetworkNativeInterFacebookAdapter.h"

@implementation AdsYumiAdNetworkNativeInterFacebookAdapter

+ (NSString*)networkType{
    return AdsYuMIAdNetworkAdFacebook;
}

+ (void)load {
    [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}


-(void)getAd{
    
    isReading = NO;
    [self adapterDidStartInterstitialRequestAd];
    
    id _timeInterval = self.provider.outTime;
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue]
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }else {
        timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }
    
    //竖屏
    [self createInterView];
    
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.key1];
    nativeAd.delegate = self;
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [nativeAd loadAd];
    
}

-(void)createInterView{
    
}

/**
 *  停止展示广告
 */
-(void)stopAd{
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
-(void)timeOutTimer{
    if (isReading) {
        return;
    }
    isReading=YES;
    [self stopTimer];
    [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestTimeOut description:@"Facebook time out"]];
}

-(void)preasentInterstitial{
    if (1) {
        
    }
}


#pragma mark FBNativeAdDelegate

/**
 Sent when an FBNativeAd has been successfully loaded.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd{
    if (isReading) {
        return;
    }
    isReading=YES;
    
    if (self._nativeAd) {
        [self._nativeAd unregisterView];
    }
    
    self._nativeAd = nativeAd;
    
    // Create native UI using the ad metadata.
    [self.adCoverMediaView setNativeAd:nativeAd];
    
    __weak typeof(self) weakSelf = self;
    [self._nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.adIconImageView.image = image;
        [self stopTimer];
        [self adapterDidInterstitialReceiveAd:self];
    }];
    self.adStatusLabel.text = @"";
    
    // Render native ads onto UIView
    self.adTitleLabel.text = self._nativeAd.title;
    self.adBodyLabel.text = self._nativeAd.body;
    self.adSocialContextLabel.text = self._nativeAd.socialContext;
    self.sponsoredLabel.text = @"Sponsored";
    
    [self.adCallToActionButton setTitle:self._nativeAd.callToAction
                                forState:UIControlStateNormal];
    
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self.adUIView
                      withViewController:self];
    
    // Or you can replace above call with following function, so you can specify the clickable areas.
    // NSArray *clickableViews = @[self.adCallToActionButton, self.adCoverMediaView];
    // [nativeAd registerViewForInteraction:self.adUIView
    //                   withViewController:self
    //                   withClickableViews:clickableViews];
    
    // Update AdChoices view
    self.adChoicesView.nativeAd = nativeAd;
    self.adChoicesView.corner = UIRectCornerTopRight;
    self.adChoicesView.hidden = NO;
    
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
    if (isReading) {
        return;
    }
    isReading=YES;
    [self stopTimer];
    [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:@"Facebook no ad"]];
}

/**
 Sent after an ad has been clicked by the person.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidClick:(FBNativeAd *)nativeAd{
    [self adapterDidInterstitialClick:self ClickArea:CGRectZero];
}

/**
 When an ad is clicked, the modal view will be presented. And when the user finishes the
 interaction with the modal view and dismiss it, this message will be sent, returning control
 to the application.
 
 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    
}
//关闭回调

-(void)dealloc
{
   
}

@end
