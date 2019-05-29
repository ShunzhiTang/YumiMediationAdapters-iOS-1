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
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.keyWindow = keyWindow;
        weakSelf.bottomView = bottomView;
        
        CGRect frame = CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height - bottomView.bounds.size.height);
        
        weakSelf.splashView = [[BUSplashAdView alloc] initWithSlotID:weakSelf.provider.data.key2 frame:frame];
        
        weakSelf.splashView.tolerateTimeout = weakSelf.fetchTime;
        weakSelf.splashView.delegate = weakSelf;
        weakSelf.splashView.rootViewController = keyWindow.rootViewController;
        
        [weakSelf.splashView loadAdData];
    });
    
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
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.keyWindow addSubview:weakSelf.splashView];
        if (weakSelf.bottomView) {
            weakSelf.bottomView.frame = CGRectMake(0,weakSelf.keyWindow.frame.size.height - weakSelf.bottomView.bounds.size.height , weakSelf.bottomView.bounds.size.width, weakSelf.bottomView.bounds.size.height);
            
            [weakSelf.keyWindow addSubview:weakSelf.bottomView];
        }
        
        [weakSelf.delegate adapter:weakSelf successToShow:splashAd];
    });
    
   
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
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.splashView) {
            [weakSelf.splashView removeFromSuperview];
        }
        if (weakSelf.bottomView) {
            [weakSelf.bottomView removeFromSuperview];
        }
        
        [weakSelf.delegate adapter:weakSelf didClose:splashAd];
    });
    
    
}

@end
