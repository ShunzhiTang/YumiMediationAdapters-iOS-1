//
//  YumiMediationVungleInstance.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import "YumiMediationVungleInstance.h"

@implementation YumiMediationVungleInstance

+ (YumiMediationVungleInstance *)sharedInstance {
    static YumiMediationVungleInstance *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YumiMediationVungleInstance alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.vungleVideoAdapters = [NSMutableArray new];
        self.vungleInterstitialAdapters = [NSMutableArray new];
    }
    return self;
}

#pragma mark : -- VungleSDKDelegate
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(nullable NSString *)placementID
                            error:(nullable NSError *)error {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID] && isAdPlayable) {
            [videoAdapter.delegate coreAdapter:videoAdapter didReceivedCoreAd:nil adType:self.adType];
        } else if ([videoAdapter.provider.data.key2 isEqualToString:placementID] && !isAdPlayable) {
             [videoAdapter.delegate coreAdapter:videoAdapter coreAd:nil didFailToLoad:@"vungle is no fill" adType:self.adType];
        }
    }

    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && isAdPlayable) {
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter didReceivedCoreAd:nil adType:self.adType];
        } else if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && !isAdPlayable) {
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter coreAd:nil didFailToLoad:@"vungle is no fill" adType:self.adType];
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID]) {
            [videoAdapter.delegate coreAdapter:videoAdapter didOpenCoreAd:nil adType:self.adType];
            [videoAdapter.delegate coreAdapter:videoAdapter didStartPlayingAd:nil adType:self.adType];
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter didOpenCoreAd:nil adType:self.adType];
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter didStartPlayingAd:nil adType:self.adType];
        }
    }
}

/**
 * If implemented, this method gets called when a Vungle Ad Unit has been completely dismissed.
 * At this point, you can load another ad for non-auto-cahced placement if necessary.
 */
- (void)vungleDidCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID]) {
            //click
            if ([info.didDownload boolValue]) {
                [videoAdapter.delegate coreAdapter:videoAdapter didClickCoreAd:nil adType:self.adType];
            }
            // reward
            if ([info.completedView boolValue]) {
                [videoAdapter.delegate coreAdapter:videoAdapter coreAd:nil didReward:YES adType:self.adType];
            }
            [videoAdapter.delegate coreAdapter:videoAdapter didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            if ([info.didDownload boolValue]) {
                [interstitialAdapter.delegate coreAdapter:interstitialAdapter didClickCoreAd:nil adType:self.adType];
            }
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
        }
    }
}

- (void)videoVungleSDKFailedToInitializeWith:(YumiMediationVideoAdapterVungle *)videoAdapter {
    [videoAdapter.delegate coreAdapter:videoAdapter coreAd:nil didFailToLoad:@"vungleSDKFailedToInitialize" adType:self.adType];
}

- (void)interstitialVungleSDKFailedToInitializeWith:(YumiMediationInterstitialAdapterVungle *)interstitialAdapter {
     [interstitialAdapter.delegate coreAdapter:interstitialAdapter coreAd:nil didFailToLoad:@"vungleSDKFailedToInitialize" adType:self.adType];
}

@end
