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
            [videoAdapter.delegate adapter:videoAdapter didReceiveVideoAd:nil];
        }
    }

    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && isAdPlayable) {
            [interstitialAdapter.delegate adapter:interstitialAdapter didReceiveInterstitialAd:nil];
        } else if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && isAdPlayable) {
            [interstitialAdapter.delegate adapter:interstitialAdapter
                                   interstitialAd:nil
                                 didFailToReceive:error.localizedDescription];
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID]) {
            [videoAdapter.delegate adapter:videoAdapter didStartPlayingVideoAd:nil];
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            [interstitialAdapter.delegate adapter:interstitialAdapter willPresentScreen:nil];
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
            [videoAdapter.delegate adapter:videoAdapter didCloseVideoAd:nil];
            if ([info.completedView boolValue]) {
                [videoAdapter.delegate adapter:videoAdapter videoAd:nil didReward:nil];
            }
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            [interstitialAdapter.delegate adapter:interstitialAdapter willDismissScreen:nil];
            if ([info.didDownload boolValue]) {
                [interstitialAdapter.delegate adapter:interstitialAdapter didClickInterstitialAd:nil];
            }
        }
    }
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
}

@end
