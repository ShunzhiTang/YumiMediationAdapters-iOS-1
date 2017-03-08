//
//  AdsYumiAdNetworkNativeAdFacebookAdapter.m
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/15.
//
//
//按比例适配代码
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
//根据 iPhone6 尺寸进行适配
#define AutoSizeScaleX ScreenWidth / 375.f
#define AutoSizeScaleY ScreenHeight / 667.f

CG_INLINE CGRect CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {

    CGRect rect;
    rect.origin.x = x * AutoSizeScaleX;
    rect.origin.y = y * AutoSizeScaleY;
    rect.size.width = width * AutoSizeScaleX;
    rect.size.height = height * AutoSizeScaleY;
    return rect;
}

#import "AdsYumiAdNetworkNativeAdFacebookAdapter.h"

@implementation AdsYumiAdNetworkNativeAdFacebookAdapter {
    //视图间隔
    float interval;
    // banner 高度
    float height;
    // banner 宽度
    float width;
}

+ (NSString *)networkType {
    return AdsYuMIAdNetworkAdFacebook;
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
        timer = [NSTimer scheduledTimerWithTimeInterval:8
                                                 target:self
                                               selector:@selector(timeOutTimer)
                                               userInfo:nil
                                                repeats:NO];
    }
    [self autoLayoutWidthAndHeight];
    [self getNibResourceFromCustomBundle];

    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.key1];
    nativeAd.delegate = self;
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [nativeAd loadAd];

    self.bannerVC.frame = CGRectMake(0, 0, width, height);
    self.adNetworkView = self.bannerVC;
}

- (void)autoLayoutWidthAndHeight {
    float h;
    float w = [UIScreen mainScreen].bounds.size.width;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        float proportion = 90.0f / 728.0f;
        h = w * proportion;
    } else {
        float proportion = 50.0f / 320.0f;
        h = w * proportion;
    }

    width = w;
    height = h;
}

- (void)getNibResourceFromCustomBundle {
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [mainBundle pathForResource:@"YumiFacebookAdapter" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    YumiFaceboolAdapterBannerVC *vc =
        [bundle loadNibNamed:@"YumiFacebookBannerNativeAdapter" owner:nil options:nil].firstObject;
    if (vc == nil) {
        NSLog(@"facebook 加载素材失败");
    }
    self.bannerVC = vc;
}

- (void)stopAd {
    isStop = YES;
    [self stopTimer];
}

- (void)timeOutTimer {

    if (isStop || isReading) {
        return;
    }
    isReading = YES;

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
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;

    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }

    self.nativeAd = nativeAd;
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self.bannerVC.adUIView
                      withViewController:[self viewControllerForPresentModalView]];

    [self.nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        self.bannerVC.adIconImageView.image = image;
        [self stopTimer];
        [self adapter:self didReceiveAdView:self.adNetworkView];
    }];

    // Render native ads onto UIView
    self.bannerVC.adTitleLabel.text = self.nativeAd.title;
    self.bannerVC.adSocialContextLabel.text = self.nativeAd.socialContext;
    [self.bannerVC.adCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    // adChoicesView
    self.adChoicesView = [[FBAdChoicesView alloc] initWithNativeAd:self.nativeAd];
    self.adChoicesView.nativeAd = nativeAd;
    self.adChoicesView.corner = UIRectCornerTopRight;
    self.adChoicesView.hidden = NO;
    [self.bannerVC.adUIView addSubview:self.adChoicesView];
    [self.adChoicesView updateFrameFromSuperview];
}

/**
 Sent immediately before the impression of an FBNativeAd object will be logged.

 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd {
}

/**
 Sent when an FBNativeAd is failed to load.

 - Parameter nativeAd: An FBNativeAd object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    if (isStop) {
        return;
    }
    if (isReading) {
        return;
    }
    isReading = YES;
    [self stopTimer];
    [self adapter:self
        didFailAd:[AdsYuMIError errorWithCode:AdYuMIRequestNotAd
                                  description:[NSString stringWithFormat:@"Facebook no ad !!! error:%@", error]]];
}

/**
 Sent after an ad has been clicked by the person.

 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self adapter:self didClickAdView:self.adNetworkView WithRect:CGRectZero];
}

/**
 When an ad is clicked, the modal view will be presented. And when the user finishes the
 interaction with the modal view and dismiss it, this message will be sent, returning control
 to the application.

 - Parameter nativeAd: An FBNativeAd object sending the message.
 */
- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
}

- (void)dealloc {
}

@end
