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

@end

@implementation YumiMediationVideoAdapterDomob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:@"10025"
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
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;
    
    self.videoManager = [[IndependentVideoManager alloc] initWithPublisherID:self.provider.data.key1 andUserID:nil];
    self.videoManager.delegate = self;
    self.videoManager.openLogger = NO;
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
}

- (void)ivManagerDidClosed:(IndependentVideoManager *)manager {
    self.available = NO;
    
    [self.delegate adapter:self didCloseVideoAd:manager];
    
    [self.delegate adapter:self videoAd:manager didReward:nil];
}

- (void)ivManager:(IndependentVideoManager *)manager isIndependentVideoAvailable:(BOOL)available {
    self.available = available;
}

@end
