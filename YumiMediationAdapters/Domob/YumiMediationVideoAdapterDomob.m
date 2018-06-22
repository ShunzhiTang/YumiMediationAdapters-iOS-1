//
//  YumiMediationVideoAdapterDomob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterDomob.h"
#import "IndependentVideoManager.h"

@interface YumiMediationVideoAdapterDomob () <IndependentVideoManagerDelegate>

@property (nonatomic) IndependentVideoManager *videoManager;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterDomob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDDomob
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];
    
    self.delegate = delegate;
    self.provider = provider;

    self.videoManager = [[IndependentVideoManager alloc] initWithPublisherID:self.provider.data.key1 andUserID:nil];
    self.videoManager.delegate = self;
    self.videoManager.openLogger = NO;
    
    return self;
}

- (void)requestAd {
    [self.videoManager checkVideoAvailable];
}

- (BOOL)isReady {
    return self.available;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.videoManager presentIndependentVideoWithViewController:rootViewController];
}

#pragma mark - IndependentVideoManagerDelegate
- (void)ivManagerDidFinishLoad:(IndependentVideoManager *)manager finished:(BOOL)isFinished {
    [self.delegate adapter:self didReceiveVideoAd:manager];
}

- (void)ivManager:(IndependentVideoManager *)manager failedLoadWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:manager didFailToLoad:[error localizedDescription]];
}

- (void)ivManagerWillPresent:(IndependentVideoManager *)manager {
    [self.delegate adapter:self didOpenVideoAd:manager];

    [self.delegate adapter:self didStartPlayingVideoAd:manager];
}

- (void)ivManagerCompletePlayVideo:(IndependentVideoManager *)manager{
    self.isReward = YES;
}

- (void)ivManagerDidClosed:(IndependentVideoManager *)manager {
    self.available = NO;
    if (self.isReward) {
        [self.delegate adapter:self videoAd:manager didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:manager];

}

- (void)ivManager:(IndependentVideoManager *)manager isIndependentVideoAvailable:(BOOL)available {
    self.available = available;
}

@end
