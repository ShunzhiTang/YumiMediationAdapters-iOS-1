//
//  YumiMediationSplashAdapterBaidu.m
//  Pods
//
//  Created by generator on 29/05/2019.
//
//

#import "YumiMediationSplashAdapterBaidu.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>
#import <BaiduMobAdSDK/BaiduMobAdSplashDelegate.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationSplashAdapterBaidu () <YumiMediationSplashAdapter, BaiduMobAdSplashDelegate>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property (nonatomic) UIWindow *keyWindow;
@property (nonatomic) UIView *bottomView;

@end

@implementation YumiMediationSplashAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerSplashAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBaidu
                                                       requestType:YumiMediationSDKAdRequest];
}

- (void)dealloc {
    [self clearSplash];
}

#pragma mark - YumiMediationSplashAdapter
- (nonnull id<YumiMediationSplashAdapter>)initWithProvider:(nonnull YumiMediationSplashProvider *)provider
                                                  delegate:(nonnull id<YumiMediationSplashAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [BaiduMobAdSetting sharedInstance].supportHttps = YES;

    return self;
}

- (NSString *)networkVersion {
    return @"4.6.5";
}

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.splash = [[BaiduMobAdSplash alloc] init];
        weakSelf.splash.AdUnitTag = weakSelf.provider.data.key2;
        weakSelf.splash.canSplashClick = YES;
        weakSelf.splash.delegate = weakSelf;
        if (!bottomView) {
            [weakSelf.splash loadAndDisplayUsingKeyWindow:keyWindow];
            return;
        }
        weakSelf.keyWindow = keyWindow;
        weakSelf.bottomView = bottomView;
        UIView *containerView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, keyWindow.bounds.size.width,
                                                     keyWindow.bounds.size.height - bottomView.bounds.size.height)];

        [weakSelf.keyWindow addSubview:containerView];
        [weakSelf.splash loadAndDisplayUsingContainerView:containerView];
    });
}

- (void)clearSplash {
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
    }
    if (self.bottomView) {
        self.bottomView = nil;
    }
    if (self.keyWindow) {
        self.keyWindow = nil;
    }
}

#pragma mark : BaiduMobAdSplashDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.bottomView) {
            weakSelf.bottomView.frame =
                CGRectMake(0, weakSelf.keyWindow.frame.size.height - weakSelf.bottomView.bounds.size.height,
                           weakSelf.bottomView.bounds.size.width, weakSelf.bottomView.bounds.size.height);

            [weakSelf.keyWindow addSubview:weakSelf.bottomView];
        }
        [weakSelf.delegate adapter:weakSelf successToShow:splash];
    });
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    [self.delegate adapter:self failToShow:[NSString stringWithFormat:@"baidu error reason %d", reason]];
    [self clearSplash];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    [self.delegate adapter:self didClick:splash];
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.bottomView removeFromSuperview];
        [weakSelf.delegate adapter:weakSelf didClose:splash];
        [weakSelf clearSplash];
    });
}
- (void)splashDidReady:(BaiduMobAdSplash *)splash AndAdType:(NSString *)adType VideoDuration:(NSInteger)videoDuration {
    [self.delegate adapter:self adLifeTime:videoDuration];
}

@end
