//
//  YumiMediationSplashAdapterGDT.m
//  Pods
//
//  Created by generator on 30/05/2019.
//
//

#import "YumiMediationSplashAdapterGDT.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiGDT/GDTSplashAd.h>

@interface YumiMediationSplashAdapterGDT () <YumiMediationSplashAdapter,GDTSplashAdDelegate>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic, assign) NSUInteger fetchTime;
@property (nonatomic) GDTSplashAd  *splash;

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

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.splash = [[GDTSplashAd alloc] initWithAppId:weakSelf.provider.data.key1 placementId:weakSelf.provider.data.key2];
        weakSelf.splash.delegate = weakSelf;
        weakSelf.splash.fetchDelay = weakSelf.fetchTime;
        
        [weakSelf.splash loadAdAndShowInWindow:keyWindow withBottomView:bottomView];
    });
}

- (void)setFetchTime:(NSUInteger)fetchTime {
    _fetchTime = fetchTime;
}

#pragma mark:GDTSplashAdDelegate

- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd{
    [self.delegate adapter:self successToShow:splashAd];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error{
    [self.delegate adapter:self failToShow:error.localizedDescription];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd{
    [self.delegate adapter:self didClick:splashAd];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd{
    [self.delegate adapter:self didClose:splashAd];
}

- (void)splashAdLifeTime:(NSUInteger)time{
    [self.delegate adapter:self adLifeTime:time];
}

@end
