//
//  YumiMediationSplashAdapterBaidu.m
//  Pods
//
//  Created by generator on 29/05/2019.
//
//

#import "YumiMediationSplashAdapterBaidu.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>
#import <BaiduMobAdSDK/BaiduMobAdSplashDelegate.h>
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>

@interface YumiMediationSplashAdapterBaidu () <YumiMediationSplashAdapter,BaiduMobAdSplashDelegate>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic) UIImage *launchImage;
@property (nonatomic, assign) NSUInteger fetchTime;
@property (nonatomic, strong) BaiduMobAdSplash *splash;

@end

@implementation YumiMediationSplashAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerSplashAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBaidu
                                                       requestType:YumiMediationSDKAdRequest];
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

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.splash = [[BaiduMobAdSplash alloc] init];
        weakSelf.splash.AdUnitTag = weakSelf.provider.data.key2;
        weakSelf.splash.canSplashClick = YES;
        weakSelf.splash.delegate = weakSelf;
        [weakSelf.splash loadAndDisplayUsingKeyWindow:keyWindow];
    });
   
}

- (void)setFetchTime:(NSUInteger)fetchTime {
    _fetchTime = fetchTime;
}

- (void)setLaunchImage:(nonnull UIImage *)launchImage {
    _launchImage = launchImage;
}

#pragma mark: BaiduMobAdSplashDelegate
- (NSString *)publisherId{
    return self.provider.data.key1;
}
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash{
    [self.delegate adapter:self successToShow:splash];
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason{
    [self.delegate adapter:self failToShow:[NSString stringWithFormat:@"baidu error reason %d",reason]];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash{
    [self.delegate adapter:self didClick:splash];
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash{
    [self.delegate adapter:self didClose:splash];
}
- (void)splashDidReady:(BaiduMobAdSplash *)splash
             AndAdType:(NSString *)adType
         VideoDuration:(NSInteger)videoDuration{
    [self.delegate adapter:self adLifeTime:videoDuration];
}

@end
