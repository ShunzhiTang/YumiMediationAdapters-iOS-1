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
#import "YumiAppOpenViewController.h"

@interface YumiMediationSplashAdapterAdMob () <YumiMediationSplashAdapter>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property(nonatomic) GADAppOpenAd *appOpenAd;
@property (nonatomic) UIView *bottomView;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

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

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    _interfaceOrientation = orientation;
}
- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
    
    self.bottomView = bottomView;
    
    self.appOpenAd = nil;
    __weak typeof(self) weakSelf = self;
    [GADAppOpenAd loadWithAdUnitID:self.provider.data.key1
                           request:[GADRequest request]
                       orientation:self.interfaceOrientation
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
    
    YumiAppOpenViewController *viewController = [[YumiAppOpenViewController alloc] init];
    
    // Don't forget to set the ad on the view controller.
    viewController.appOpenAd = self.appOpenAd;
    viewController.bottomView = self.bottomView;
    // Set a block to request a new ad.
    viewController.onViewControllerClosed = ^{
        [weakSelf.delegate adapter:weakSelf didClose:weakSelf.appOpenAd];
    };
    
   [[[YumiTool sharedTool] topMostController] presentViewController:viewController
                                                                animated:NO
                                                         completion:^{
                                                             [weakSelf.delegate adapter:weakSelf successToShow:weakSelf.appOpenAd];
                                                         }];
    
}

@end
