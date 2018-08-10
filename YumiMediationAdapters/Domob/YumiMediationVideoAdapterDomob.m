//
//  YumiMediationVideoAdapterDomob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterDomob.h"
#import "DMAdVideoManager.h"
#import <YumiMediationSDK/YumiLogger.h>
#import <YumiMediationSDK/YumiMediationConstants.h>

@interface YumiMediationVideoAdapterDomob () <DMAdVideoManagerDelegate>

@property (nonatomic) DMAdVideoManager *videoManager;
@property (nonatomic, assign) BOOL available;

@end

@implementation YumiMediationVideoAdapterDomob

+ (void)load {
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [[YumiLogger stdLogger] info:@"Domob don't support iOS version below 9.0"];
        return;
    }
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDDomob
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    self.videoManager = [[DMAdVideoManager alloc] initWithPublisherID:self.provider.data.key1];
    self.videoManager.delegate = self;

    return self;
}

- (void)requestAd {
    [self.videoManager loadAd];
}

- (BOOL)isReady {
    return self.available;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.videoManager presentADVideoControllerWithViewController:rootViewController];
}

#pragma mark - IndependentVideoManagerDelegate
- (void)AdVideoManagerDidFinishLoad:(DMAdVideoManager *_Nonnull)manager {
    self.available = YES;
    [self.delegate adapter:self didReceiveVideoAd:manager];
}

- (void)AdVideoManager:(DMAdVideoManager *_Nonnull)manager failedLoadWithError:(NSError *__nullable)error {
    self.available = NO;
    [self.delegate adapter:self videoAd:manager didFailToLoad:[error localizedDescription]];
}

- (void)AdVideoManagerPlayVideoComplete:(DMAdVideoManager *_Nonnull)manager {
    self.available = NO;
    [self.delegate adapter:self videoAd:manager didReward:nil];
}

- (void)AdVideoManagerCloseVideoPlayer:(DMAdVideoManager *_Nonnull)manager {
    self.available = NO;
    [self.delegate adapter:self didCloseVideoAd:manager];
}

@end
