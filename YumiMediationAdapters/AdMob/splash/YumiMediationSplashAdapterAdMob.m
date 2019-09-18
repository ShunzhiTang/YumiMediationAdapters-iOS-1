//
//  YumiMediationSplashAdapterAdMob.m
//  Pods
//
//  Created by generator on 04/06/2019.
//
//

#import "YumiMediationSplashAdapterAdMob.h"
#import "YumiAppOpenViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationSplashAdapterAdMob () <YumiMediationSplashAdapter>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic) GADAppOpenAd *appOpenAd;
@property (nonatomic) UIView *bottomView;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, assign) BOOL isTimeout;
@property (nonatomic) dispatch_block_t timeoutBlock;
@property (nonatomic, assign) BOOL loadComplete;

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

- (NSString *)networkVersion {
    return @"7.44.0";
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    _interfaceOrientation = orientation;
}
- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {

    self.isTimeout = NO;
    self.loadComplete = NO;
    if (self.timeoutBlock) {
        dispatch_block_cancel(self.timeoutBlock);
    }
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    GADExtras *extras = [[GADExtras alloc] init];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        extras.additionalParameters = @{@"npa" : @"0"};
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        extras.additionalParameters = @{@"npa" : @"1"};
    }

    GADRequest *request = [GADRequest request];
    [request registerAdNetworkExtras:extras];

    self.bottomView = bottomView;

    self.appOpenAd = nil;
    __weak typeof(self) weakSelf = self;
    [GADAppOpenAd loadWithAdUnitID:self.provider.data.key1
                           request:request
                       orientation:self.interfaceOrientation
                 completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
                     if (weakSelf.isTimeout) {
                         return;
                     }
                     self.loadComplete = YES;
                     if (error) {
                         [weakSelf.delegate adapter:weakSelf failToShow:error.localizedDescription];
                         return;
                     }
                     weakSelf.appOpenAd = appOpenAd;
                     [weakSelf showSplash];
                 }];
    // timeout
    self.timeoutBlock = dispatch_block_create(0, ^{
        if (weakSelf.loadComplete) {
            return;
        }
        weakSelf.isTimeout = YES;
        [weakSelf.delegate adapter:weakSelf failToShow:@"admob splash time out"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.provider.data.requestTimeout * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), self.timeoutBlock);
}

- (void)showSplash {
    __weak typeof(self) weakSelf = self;
    YumiAppOpenViewController *viewController = [[YumiAppOpenViewController alloc] init];

    // Don't forget to set the ad on the view controller.
    viewController.appOpenAd = self.appOpenAd;
    viewController.bottomView = self.bottomView;
    // Set a block to request a new ad.
    viewController.onViewControllerClosed = ^{
        weakSelf.appOpenAd = nil;
        [weakSelf.delegate adapter:weakSelf didClose:weakSelf.appOpenAd];
    };

    [[[YumiTool sharedTool] topMostController]
        presentViewController:viewController
                     animated:NO
                   completion:^{
                       [weakSelf.delegate adapter:weakSelf successToShow:weakSelf.appOpenAd];
                   }];
}

@end
