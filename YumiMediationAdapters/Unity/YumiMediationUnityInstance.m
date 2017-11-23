//
//  YumiMediationUnityInstance.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/11/22.
//

#import "YumiMediationUnityInstance.h"

@interface YumiMediationUnityInstance ()

@end

@implementation YumiMediationUnityInstance

+ (YumiMediationUnityInstance *)sharedInstance {
    static YumiMediationUnityInstance *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YumiMediationUnityInstance alloc] init];
    });
    return sharedInstance;
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate adapter:self.unityInterstitialAdapter didReceiveInterstitialAd:nil];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter didReceiveVideoAd:nil];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    [self.unityInterstitialAdapter.delegate adapter:self.unityInterstitialAdapter
                                     interstitialAd:nil
                                   didFailToReceive:message];

    [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter videoAd:nil didFailToLoad:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate adapter:self.unityInterstitialAdapter willPresentScreen:nil];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter didOpenVideoAd:nil];

        [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter didStartPlayingVideoAd:nil];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate adapter:self.unityInterstitialAdapter willDismissScreen:nil];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter didCloseVideoAd:nil];

        if (state == kUnityAdsFinishStateCompleted) {
            [self.unityVideoAdapter.delegate adapter:self.unityVideoAdapter videoAd:nil didReward:nil];
        }
    }
}

@end
