//
//  YumiMediationSplashAdapterBytedanceAds.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/5/29.
//

#import "YumiMediationSplashAdapterBytedanceAds.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationSplashAdapterBytedanceAds () <YumiMediationSplashAdapter>

@property (nonatomic, weak) id<YumiMediationSplashAdapterDelegate> delegate;
@property (nonatomic) YumiMediationSplashProvider *provider;

@property (nonatomic) UIImage *launchImage;
@property (nonatomic, assign) NSUInteger fetchTime;

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

    return self;
}

- (void)requestAdAndShowInWindow:(nonnull UIWindow *)keyWindow withBottomView:(nonnull UIView *)bottomView {
}

- (void)setFetchTime:(NSUInteger)fetchTime {
    _fetchTime = fetchTime;
}

- (void)setLaunchImage:(nonnull UIImage *)launchImage {
    _launchImage = launchImage;
}

@end
