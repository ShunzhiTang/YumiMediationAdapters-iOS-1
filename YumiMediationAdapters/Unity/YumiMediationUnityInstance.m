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
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                          didReceivedCoreAd:nil
                                                     adType:YumiMediationAdTypeInterstitial];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                   didReceivedCoreAd:nil
                                              adType:YumiMediationAdTypeVideo];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {

    // show or player ad fail
    if (error == kUnityAdsErrorShowError || error == kUnityAdsErrorVideoPlayerError) {
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                             failedToShowAd:nil
                                                errorString:message
                                                     adType:YumiMediationAdTypeInterstitial];

        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                      failedToShowAd:nil
                                         errorString:message
                                              adType:YumiMediationAdTypeVideo];
        return;
    }
    [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                                 coreAd:nil
                                          didFailToLoad:message
                                                 adType:YumiMediationAdTypeInterstitial];

    [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                          coreAd:nil
                                   didFailToLoad:message
                                          adType:YumiMediationAdTypeVideo];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {

        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                              didOpenCoreAd:nil
                                                     adType:YumiMediationAdTypeInterstitial];
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                          didStartPlayingAd:nil
                                                     adType:YumiMediationAdTypeInterstitial];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {

        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                       didOpenCoreAd:nil
                                              adType:YumiMediationAdTypeVideo];
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                   didStartPlayingAd:nil
                                              adType:YumiMediationAdTypeVideo];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if(state == kUnityAdsFinishStateError){
        if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
            [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                                 failedToShowAd:nil
                                                    errorString:@"the ad did not successfully display."
                                                    adType:YumiMediationAdTypeInterstitial];
        } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
            [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                          failedToShowAd:nil
                                             errorString:@"the ad did not successfully display."
                                                  adType:YumiMediationAdTypeVideo];
        }
        
        return;
    }

    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                             didCloseCoreAd:nil
                                          isCompletePlaying:NO
                                                     adType:YumiMediationAdTypeInterstitial];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {

        if (state == kUnityAdsFinishStateCompleted) {
            [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                                  coreAd:nil
                                               didReward:YES
                                                  adType:YumiMediationAdTypeVideo];
            [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                          didCloseCoreAd:nil
                                       isCompletePlaying:YES
                                                  adType:YumiMediationAdTypeVideo];
            return;
        }
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                      didCloseCoreAd:nil
                                   isCompletePlaying:NO
                                              adType:YumiMediationAdTypeVideo];
    }
}

- (void)unityAdsDidClick:(NSString *)placementId{
    if ([self.unityInterstitialAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityInterstitialAdapter.delegate coreAdapter:self.unityInterstitialAdapter
                                          didClickCoreAd:nil
                                                     adType:YumiMediationAdTypeInterstitial];
    } else if ([self.unityVideoAdapter.provider.data.key2 isEqualToString:placementId]) {
        [self.unityVideoAdapter.delegate coreAdapter:self.unityVideoAdapter
                                   didClickCoreAd:nil
                                              adType:YumiMediationAdTypeVideo];
    }
}

- (void)unityAdsPlacementStateChanged:(nonnull NSString *)placementId oldState:(UnityAdsPlacementState)oldState newState:(UnityAdsPlacementState)newState {
    
}


@end
