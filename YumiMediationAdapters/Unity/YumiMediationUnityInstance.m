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
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter didReceivedCoreAd:nil adType:self.adType];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter didReceivedCoreAd:nil adType:self.adType];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    
    // show or player ad fail
    if (error == kUnityAdsErrorShowError || error == kUnityAdsErrorVideoPlayerError) {
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter failedToShowAd:nil errorString:message adType:self.adType];
        
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter failedToShowAd:nil errorString:message adType:self.adType];
        return;
    }
    [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter coreAd:nil didFailToLoad:message adType:self.adType];

    [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter coreAd:nil didFailToLoad:message adType:self.adType];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter didOpenCoreAd:nil adType:self.adType];
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter didStartPlayingAd:nil adType:self.adType];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {

        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter didOpenCoreAd:nil adType:self.adType];
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter didStartPlayingAd:nil adType:self.adType];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {

        if (state == kUnityAdsFinishStateCompleted) {
             [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter coreAd:nil didReward:YES adType:self.adType];
        }
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
    }
}

@end
