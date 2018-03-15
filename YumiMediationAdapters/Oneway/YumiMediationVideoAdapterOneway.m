//
//  YumiMediationVideoAdapterOneway.m
//  Pods
//
//  Created by d on 30/10/2017.
//
//

#import "YumiMediationVideoAdapterOneway.h"
#import <OneWaySDK.h>

@interface YumiMediationVideoAdapterOneway () <oneWaySDKRewardedAdDelegate>

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

    [OneWaySDK configure:self.provider.data.key1];
}

- (void)requestAd {
    if ([OneWaySDK isConfigured]) {
        [OWRewardedAd initWithDelegate:self];
    } else {
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"OneWaySDK no configured"];
    }
}

- (BOOL)isReady {
    return [OWRewardedAd isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [OWRewardedAd show:rootViewController];
}

#pragma mark : oneWaySDKRewardedAdDelegate
- (void)oneWaySDKRewardedAdReady {
    [self.delegate adapter:self didReceiveVideoAd:nil];
}

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
    [self.delegate adapter:self didOpenVideoAd:nil];
}

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    if ([state integerValue] == kOneWaySDKFinishStateCompleted) {
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }

    [self.delegate adapter:self didCloseVideoAd:nil];
}

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag {
}
- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message {
    [self.delegate adapter:self videoAd:nil didFailToLoad:message];
}

@end
