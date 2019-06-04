//
//  YumiMediationSplashAdapterAdMob.m
//  Pods
//
//  Created by generator on 04/06/2019.
//
//

#import "YumiMediationSplashAdapterAdMob.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationSplashAdapterAdMob () <YumiMediationSplashAdapter>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property(nonatomic) GADAppOpenAd* appOpenAd;
@property(strong, nonatomic) GADAppOpenAdView* appOpenAdView;
@property (nonatomic) UIWindow *keyWindow;
@property (nonatomic) UIView *bottomView;
@property (nonatomic) UIViewController *adViewController;
@property (nonatomic) UIView  *superView;

@end

@implementation YumiMediationSplashAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerSplashAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAdMob
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationSplashAdapter
- (nonnull id<YumiMediationSplashAdapter>)initWithProvider:(nonnull YumiMediationSplashProvider *)provider
                                                  delegate:(nonnull id<YumiMediationSplashAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        return self;
    }
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
    }];

    return self;
}

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
    
    self.keyWindow = keyWindow;
    self.bottomView = bottomView;
    
    self.appOpenAd = nil;
    self.appOpenAdView = nil;
    __weak typeof(self) weakSelf = self;
    [GADAppOpenAd loadWithAdUnitID:self.provider.data.key1
                           request:[GADRequest request]
                       orientation:UIInterfaceOrientationPortrait
                 completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
                     if (error) {
                         NSLog(@"Failed to load app open ad: %@", error);
                         [weakSelf.delegate adapter:weakSelf failToShow:error.localizedDescription];
                         return;
                     }
                     weakSelf.appOpenAd = appOpenAd;
                     [weakSelf showSplash];
                 }];
    
}

- (void)showSplash{
    
    __weak typeof(self) weakSelf = self;
    
    GADAppOpenAdCloseHandler adCloseHandler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.bottomView removeFromSuperview];
            [weakSelf.appOpenAdView removeFromSuperview];
            [weakSelf.superView removeFromSuperview];
            
            [weakSelf.delegate adapter:weakSelf didClose:weakSelf.appOpenAdView];
        });
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // add superview for background
        [weakSelf.keyWindow addSubview:weakSelf.superView];
        
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat marginTop = 0;
        if ([[YumiTool sharedTool] isiPhoneX]) {
            height = kIPHONEXHEIGHT - kIPHONEXSTATUSBAR - kIPHONEXHOMEINDICATOR;
            marginTop = kIPHONEXSTATUSBAR;
        }
        if ([[YumiTool sharedTool] isiPhoneXR]) {
            height = kIPHONEXRHEIGHT - kIPHONEXRSTATUSBAR - kIPHONEXRHOMEINDICATOR;
            marginTop = kIPHONEXSTATUSBAR;
        }
        
        CGFloat defaultHeight = height * 0.85 ;
        
        CGFloat adHeight =  height - weakSelf.bottomView.bounds.size.height > defaultHeight ? height - weakSelf.bottomView.bounds.size.height : defaultHeight;
        
        CGRect frame =
        CGRectMake(0, marginTop, weakSelf.keyWindow.frame.size.width, adHeight);
        
        if (weakSelf.bottomView) {
            weakSelf.bottomView.frame =
            CGRectMake(0, adHeight + marginTop,
                       weakSelf.bottomView.bounds.size.width, weakSelf.bottomView.bounds.size.height);
            
            [weakSelf.superView addSubview:weakSelf.bottomView];
        }
        
         weakSelf.appOpenAdView = [[GADAppOpenAdView alloc] initWithFrame:frame];
        
        [weakSelf.superView addSubview:weakSelf.appOpenAdView];
        
        // Make sure to set the `GADAppOpenAdCloseHandler` and the `GADAppOpenAd` on your `GADAppOpenAdView`.
        weakSelf.appOpenAdView.adCloseHandler = adCloseHandler;
        weakSelf.appOpenAdView.appOpenAd = weakSelf.appOpenAd;
        
        [weakSelf.delegate adapter:weakSelf successToShow:weakSelf.appOpenAdView];
    });
}

- (UIView *)superView{
    if (!_superView) {
        _superView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _superView.backgroundColor = [UIColor blackColor];
    }
    return _superView;
}

@end
