//
//  YumiMediationSplashAdapterGDT.m
//  Pods
//
//  Created by generator on 30/05/2019.
//
//

#import "YumiMediationSplashAdapterGDT.h"
#import <YumiGDT/GDTSplashAd.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationSplashAdapterGDT () <YumiMediationSplashAdapter, GDTSplashAdDelegate>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic) GDTSplashAd *splash;

@end

@implementation YumiMediationSplashAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerSplashAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDGDT
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationSplashAdapter
- (nonnull id<YumiMediationSplashAdapter>)initWithProvider:(nonnull YumiMediationSplashProvider *)provider
                                                  delegate:(nonnull id<YumiMediationSplashAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (NSString *)networkVersion {
    return @"4.10.10";
}

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.splash =
            [[GDTSplashAd alloc] initWithAppId:weakSelf.provider.data.key1 placementId:weakSelf.provider.data.key2];
        weakSelf.splash.delegate = weakSelf;
        weakSelf.splash.fetchDelay = weakSelf.provider.data.requestTimeout;

        [weakSelf.splash loadAdAndShowInWindow:keyWindow withBottomView:bottomView];
    });
}

#pragma mark :GDTSplashAdDelegate

- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    [self.delegate adapter:self successToShow:splashAd];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    [self.delegate adapter:self failToShow:error.localizedDescription];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.delegate adapter:self didClick:splashAd];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    [self.delegate adapter:self didClose:splashAd];
}

- (void)splashAdLifeTime:(NSUInteger)time {
    [self.delegate adapter:self adLifeTime:time];
}
/// 当点击下载应用时会调用系统程序打开，应用切换到后台
- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
    [self.delegate adapter:self didClose:splashAd];
}
@end
