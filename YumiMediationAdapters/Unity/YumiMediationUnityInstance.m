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

#pragma mark : - private method
- (NSString *)getAdapterKeyWith:(NSString *)placementId adType:(YumiMediationAdType)adType {
    return [NSString stringWithFormat:@"%@_%ld", placementId, adType];
}

- (NSString *)adapterKey:(NSString *)placementId {
    __block NSString *adapterKey = nil;
    [self.adaptersDict.allKeys
        enumerateObjectsUsingBlock:^(NSString *_Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([key containsString:placementId]) {
                adapterKey = key;
            }
        }];
    return adapterKey;
}

- (id<YumiMediationCoreAdapter>)adapterObject:(NSString *)placementId {
    return self.adaptersDict[[self adapterKey:placementId]];
}

- (NSUInteger)adapterAdType:(NSString *)placementId {
    NSString *adapterKey = [self adapterKey:placementId];

    NSArray *components = [adapterKey componentsSeparatedByString:@"_"];

    if (components.count == 2) {
        return [components.lastObject integerValue];
    }
    return 0;
}

- (void)delegateErrorIfNeed:(BOOL)isLoadFail errorMsg:(NSString *)errorMsg {

    // call back all adapters
    [self.adaptersDict
        enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id<YumiMediationCoreAdapter> _Nonnull coreAdapter,
                                            BOOL *_Nonnull stop) {

            NSArray *components = [key componentsSeparatedByString:@"_"];
            if (components.count != 2) {
                return;
            }

            YumiMediationAdType adType = (YumiMediationAdType)components.lastObject;

            if (isLoadFail) {
                if (adType == YumiMediationAdTypeInterstitial) {

                    [((YumiMediationInterstitialAdapterUnity *)coreAdapter).delegate coreAdapter:coreAdapter
                                                                                          coreAd:nil
                                                                                   didFailToLoad:errorMsg
                                                                                          adType:adType];
                }
                if (adType == YumiMediationAdTypeVideo) {

                    [((YumiMediationVideoAdapterUnity *)coreAdapter).delegate coreAdapter:coreAdapter
                                                                                   coreAd:nil
                                                                            didFailToLoad:errorMsg
                                                                                   adType:adType];
                }
                return;
            }
            // fail to show
            if (adType == YumiMediationAdTypeInterstitial) {

                [((YumiMediationInterstitialAdapterUnity *)coreAdapter).delegate coreAdapter:coreAdapter
                                                                              failedToShowAd:nil
                                                                                 errorString:errorMsg
                                                                                      adType:adType];
            }
            if (adType == YumiMediationAdTypeVideo) {

                [((YumiMediationVideoAdapterUnity *)coreAdapter).delegate coreAdapter:coreAdapter
                                                                       failedToShowAd:nil
                                                                          errorString:errorMsg
                                                                               adType:adType];
            }

        }];
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {

    NSUInteger adType = [self adapterAdType:placementId];

    if (adType == 0) {
        return;
    }

    id<YumiMediationCoreAdapter> adapter = [self adapterObject:placementId];

    if (adType == YumiMediationAdTypeInterstitial) {

        [((YumiMediationInterstitialAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                               didReceivedCoreAd:nil
                                                                          adType:YumiMediationAdTypeInterstitial];

        return;
    }
    if (adType == YumiMediationAdTypeVideo) {
        [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                        didReceivedCoreAd:nil
                                                                   adType:YumiMediationAdTypeVideo];
        return;
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {

    // show or player ad fail
    if (error == kUnityAdsErrorShowError || error == kUnityAdsErrorVideoPlayerError) {

        [self delegateErrorIfNeed:NO errorMsg:message];

        return;
    }
    [self delegateErrorIfNeed:YES errorMsg:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSUInteger adType = [self adapterAdType:placementId];

    if (adType == 0) {
        return;
    }

    id<YumiMediationCoreAdapter> adapter = [self adapterObject:placementId];

    if (adType == YumiMediationAdTypeInterstitial) {
        [((YumiMediationInterstitialAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                                   didOpenCoreAd:nil
                                                                          adType:YumiMediationAdTypeInterstitial];
        [((YumiMediationInterstitialAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                               didStartPlayingAd:nil
                                                                          adType:YumiMediationAdTypeInterstitial];
        return;
    }

    if (adType == YumiMediationAdTypeVideo) {
        [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                            didOpenCoreAd:nil
                                                                   adType:YumiMediationAdTypeVideo];
        [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                        didStartPlayingAd:nil
                                                                   adType:YumiMediationAdTypeVideo];
        return;
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if (state == kUnityAdsFinishStateError) {

        [self delegateErrorIfNeed:NO errorMsg:@"the ad did not successfully display."];
        return;
    }

    NSUInteger adType = [self adapterAdType:placementId];

    if (adType == 0) {
        return;
    }

    id<YumiMediationCoreAdapter> adapter = [self adapterObject:placementId];

    if (adType == YumiMediationAdTypeInterstitial) {
        [((YumiMediationInterstitialAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                                  didCloseCoreAd:adapter
                                                               isCompletePlaying:NO
                                                                          adType:YumiMediationAdTypeInterstitial];
        return;
    }

    if (adType == YumiMediationAdTypeVideo) {
        if (state == kUnityAdsFinishStateCompleted) {
            [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                                       coreAd:nil
                                                                    didReward:YES
                                                                       adType:YumiMediationAdTypeVideo];
            [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                               didCloseCoreAd:nil
                                                            isCompletePlaying:YES
                                                                       adType:YumiMediationAdTypeVideo];
            return;
        }
        [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                           didCloseCoreAd:nil
                                                        isCompletePlaying:NO
                                                                   adType:YumiMediationAdTypeVideo];
        return;
    }
}

- (void)unityAdsDidClick:(NSString *)placementId {
    NSUInteger adType = [self adapterAdType:placementId];

    if (adType == 0) {
        return;
    }

    id<YumiMediationCoreAdapter> adapter = [self adapterObject:placementId];

    if (adType == YumiMediationAdTypeInterstitial) {
        [((YumiMediationInterstitialAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                                  didClickCoreAd:nil
                                                                          adType:YumiMediationAdTypeInterstitial];
        return;
    }
    if (adType == YumiMediationAdTypeVideo) {
        [((YumiMediationVideoAdapterUnity *)adapter).delegate coreAdapter:adapter
                                                           didClickCoreAd:nil
                                                                   adType:YumiMediationAdTypeVideo];
        return;
    }
}
- (void)unityAdsPlacementStateChanged:(NSString *)placementId
                             oldState:(UnityAdsPlacementState)oldState
                             newState:(UnityAdsPlacementState)newState {
}

#pragma mark : getter method
- (NSMutableDictionary<NSString *, id<YumiMediationCoreAdapter>> *)adaptersDict {
    if (!_adaptersDict) {
        _adaptersDict = [NSMutableDictionary dictionary];
    }
    return _adaptersDict;
}

@end
