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

#pragma mark : -- VungleSDKDelegate
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID {
    // video
    if ([placementID isEqualToString:self.vungleVideoAdapter.provider.data.key2]) {
        if (isAdPlayable) {
            [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didReceiveVideoAd:nil];
        }
    } else if ([placementID isEqualToString:self.vungleInterstitialAdapter.provider.data.key3]) {
        if (isAdPlayable) {
            [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter
                                    didReceiveInterstitialAd:nil];
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    if ([placementID isEqualToString:self.vungleVideoAdapter.provider.data.key2]) {
        [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didOpenVideoAd:nil];
        [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didStartPlayingVideoAd:nil];

    } else if ([placementID isEqualToString:self.vungleInterstitialAdapter.provider.data.key3]) {
        [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter willPresentScreen:nil];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID {
    if ([placementID isEqualToString:self.vungleVideoAdapter.provider.data.key2]) {
        if ([info.completedView boolValue]) {
            [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter videoAd:nil didReward:nil];
        }
        [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didCloseVideoAd:nil];
    } else if ([placementID isEqualToString:self.vungleInterstitialAdapter.provider.data.key3]) {
        [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter willDismissScreen:nil];
        if ([info.didDownload boolValue]) {
            [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter didClickInterstitialAd:nil];
        }
    }
}

- (void)vungleSDKDidInitialize {
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter
                                      videoAd:nil
                                didFailToLoad:[error localizedDescription]];
    [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter
                                      interstitialAd:nil
                                    didFailToReceive:[error localizedDescription]];
}

@end
