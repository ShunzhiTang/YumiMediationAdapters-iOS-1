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

@implementation AdsYumiAdNetworkNativeInterFacebookAdapter{
    BOOL isReady;
}

+ (NSString*)networkType{
    return AdsYuMIAdNetworkAdFacebook;
}

+ (void)load {
    [[AdsYuMIInterstitialSDKAdNetworkRegistry sharedRegistry] registerClass:self];
}


-(void)getAd{
    
    isReading = NO;
    isReady = NO;
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
    
    self.intestitialView = [self createInterstitialVc];
    
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.key1];
    nativeAd.delegate = self;
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [nativeAd loadAd];
    
}
//获取图片资源文件
-(UIImage *)getBundleResourcesFromCustomBundle:(NSString *)name type:(NSString *)type{
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [mainBundle pathForResource:@"YumiFacebookAdapter" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
        NSString *resourcesPath = [bundle pathForResource:[NSString stringWithFormat:@"%@%@",name,@"@2x"] ofType:type];
        UIImage *storyMenuItemImage = [UIImage imageWithContentsOfFile:resourcesPath];
        if (storyMenuItemImage==nil) {
            NSLog(@"facebook 加载素材失败");
        }
        return storyMenuItemImage;
}
//获取 nib 资源
-(UIViewController *)getNibResourceFromCustomBundle:(NSString *)name type:(NSString *)type{
    [FBMediaView class];
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [mainBundle pathForResource:@"YumiFacebookAdapter" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIViewController *vc = [bundle loadNibNamed:name owner:nil options:nil].firstObject;
        if (vc == nil) {
            NSLog(@"facebook 加载素材失败");
        }
        return vc;
}

-(YumiFacebookAdapterInterstitialVc *)createInterstitialVc{
    //关闭按钮
    UIImage *closeImage = [self getBundleResourcesFromCustomBundle:@"adsyumi_adClose2"type:@"png"];
    
    YumiFacebookAdapterInterstitialVc *interstitial = [self getNibResourceFromCustomBundle:@"YumiFacebookInterstitialNativeAdapter" type:@"nib"] ;
    
    return interstitial;
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
    if (isReady) {
        UIViewController *vc = [self viewControllerForWillPresentInterstitialModalView];
        [vc presentViewController:self.intestitialView animated:YES completion:^{
        }];
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
    if (isReady) {
        return;
    }
    isReading=YES;
    
    if (self._nativeAd) {
        [self._nativeAd unregisterView];
    }
    
    self._nativeAd = nativeAd;
    
    // Create native UI using the ad metadata.
    [self.intestitialView.adCoverMediaView setNativeAd:nativeAd];
    
    [self._nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        self.intestitialView.adIconImageView.image = image;
        isReady = YES;
        [self stopTimer];
        [self adapterDidInterstitialReceiveAd:self];
    }];
    
    // Render native ads onto UIView
    self.intestitialView.adTitleLabel.text = self._nativeAd.title;
    self.intestitialView.adBodyLabel.text = self._nativeAd.body;
    self.intestitialView.adSocialContextLabel.text = self._nativeAd.socialContext;
    self.intestitialView.sponsoredLabel.text = @"Sponsored";
    [self.intestitialView.adCallToActionButton setHidden:NO];
    [self.intestitialView.adCallToActionButton setTitle:self._nativeAd.callToAction
                                forState:UIControlStateNormal];
    
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self.intestitialView.adUIView
                      withViewController:self];
    
    // Update AdChoices view
    self.intestitialView.adChoicesView.nativeAd = nativeAd;
    self.intestitialView.adChoicesView.corner = UIRectCornerTopRight;
    self.intestitialView.adChoicesView.hidden = NO;
    
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
    [self adapter:self didInterstitialFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd description:[NSString stringWithFormat:@"Facebook no ad !!! error:%@",error]]];
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
-(void)closeFacebookIntestitial{
    [[self viewControllerForWillPresentInterstitialModalView] dismissViewControllerAnimated:YES completion:nil];;
}

#pragma mark FBMediaViewDelegate
/**
 Sent when an FBMediaView has been successfully loaded.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewDidLoad:(FBMediaView *)mediaView{
    
}

/**
 Sent just before an FBMediaView will enter the fullscreen layout.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewWillEnterFullscreen:(FBMediaView *)mediaView{
    
}

/**
 Sent after an FBMediaView has exited the fullscreen layout.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewDidExitFullscreen:(FBMediaView *)mediaView{
    
}

/**
 Sent when an FBMediaView has changed the playback volume of a video ad.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 - Parameter volume: The current ad video volume (after the volume change).
 */
- (void)mediaView:(FBMediaView *)mediaView videoVolumeDidChange:(float)volume{
    
}

/**
 Sent after a video ad in an FBMediaView enters a paused state.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewVideoDidPause:(FBMediaView *)mediaView{
    
}

/**
 Sent after a video ad in an FBMediaView enters a playing state.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewVideoDidPlay:(FBMediaView *)mediaView{
    
}

/**
 Sent when a video ad in an FBMediaView reaches the end of playback.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewVideoDidComplete:(FBMediaView *)mediaView{
    
}


-(void)dealloc
{
   
}

@end
