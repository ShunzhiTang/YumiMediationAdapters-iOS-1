//
//  YumiMediationVideoAdapterOneway.m
//  Pods
//
//  Created by d on 30/10/2017.
//
//

#import "YumiMediationVideoAdapterOneway.h"
#import <OneWaySDK.h>

@interface YumiMediationVideoAdapterOneway () <OneWaySDKDelegate>

@end

@implementation YumiMediationVideoAdapterOneway

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDOneWay
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
}

- (void)requestAd {
    [OneWaySDK initialize:self.provider.data.key1 delegate:self];
}

- (BOOL)isReady {
    return [OneWaySDK isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [OneWaySDK show:rootViewController];
}

#pragma mark - OneWaySDKDelegate
- (void)oneWaySDKReady:(NSString *)placementId {
    [self.delegate adapter:self didReceiveVideoAd:placementId];
}

- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message {
    [self.delegate adapter:self videoAd:nil didFailToLoad:message];
}

- (void)oneWaySDKDidStart:(NSString *)placementId {
    [self.delegate adapter:self didStartPlayingVideoAd:placementId];
    [self.delegate adapter:self didOpenVideoAd:placementId];
}

- (void)oneWaySDKDidFinish:(NSString *)placementId withFinishState:(OneWaySDKFinishState)state {

    switch (state) {
        case kOneWaySDKFinishStateError:
            [self.delegate adapter:self videoAd:placementId didFailToLoad:@"the ad did not successfully display"];
            break;
        case kOneWaySDKFinishStateSkipped:
            [self.delegate adapter:self didCloseVideoAd:placementId];
            break;
        case kOneWaySDKFinishStateCompleted:
            [self.delegate adapter:self didCloseVideoAd:placementId];
            [self.delegate adapter:self videoAd:placementId didReward:nil];
            break;
        default:
            break;
    }
}

@end
