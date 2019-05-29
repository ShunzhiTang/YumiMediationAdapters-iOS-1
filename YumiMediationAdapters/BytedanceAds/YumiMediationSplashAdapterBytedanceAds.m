//
//  YumiMediationSplashAdapterBytedanceAds.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/5/29.
//

#import "YumiMediationSplashAdapterBytedanceAds.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <BUAdSDK/BUAdSDK.h>

@interface YumiMediationSplashAdapterBytedanceAds () <YumiMediationSplashAdapter,BUSplashAdDelegate>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic) UIImage *launchImage;
@property (nonatomic, assign) NSUInteger fetchTime;

@property (nonatomic) BUSplashAdView *splashView;
@property (nonatomic) UIWindow  *keyWindow;
@property (nonatomic) UIView  *bottomView;

@end

@implementation YumiMediationSplashAdapterBytedanceAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerSplashAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDBytedanceAds
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationSplashAdapter
- (nonnull id<YumiMediationSplashAdapter>)initWithProvider:(nonnull YumiMediationSplashProvider *)provider
                                                  delegate:(nonnull id<YumiMediationSplashAdapterDelegate>)delegate {

    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    
    [BUAdSDKManager setAppID:provider.data.key1];
    
    return self;
}

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
    
    self.keyWindow = keyWindow;
    self.bottomView = bottomView;
    
    CGRect frame = CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height - bottomView.bounds.size.height);
    
    self.splashView = [[BUSplashAdView alloc] initWithSlotID:self.provider.data.key2 frame:frame];
    
    self.splashView.tolerateTimeout = self.fetchTime;
    self.splashView.delegate = self;
    self.splashView.rootViewController = keyWindow.rootViewController;
    
    [self.splashView loadAdData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.fetchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}

- (void)setFetchTime:(NSUInteger)fetchTime {
    _fetchTime = fetchTime;
}

- (void)setLaunchImage:(nonnull UIImage *)launchImage {
    _launchImage = launchImage;
}

#pragma mark:BUSplashAdDelegate

- (void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    
    [self.keyWindow addSubview:self.splashView];
    [self.keyWindow addSubview:self.bottomView];
    
    [self.delegate adapter:self successToShow:splashAd];
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self failToShow:error.localizedDescription];
}

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    
}

- (void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [self.delegate adapter:self didClick:splashAd];
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [self.delegate adapter:self didClose:splashAd];
}

@end
