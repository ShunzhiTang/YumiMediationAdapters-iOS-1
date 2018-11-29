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
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(nullable NSString *)placementID
                            error:(nullable NSError *)error {
    if (isAdPlayable) {
        [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didReceiveVideoAd:nil instanceId:placementID];
        [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter
                                    didReceiveInterstitialAd:nil instanceId:placementID];
    } else {
        [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter interstitialAd:nil didFailToReceive:error.localizedDescription instanceId:placementID];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
}

/**
 * If implemented, this method gets called when a Vungle Ad Unit has been completely dismissed.
 * At this point, you can load another ad for non-auto-cahced placement if necessary.
 */
- (void)vungleDidCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID {
    if ([info.completedView boolValue]) {
        [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter videoAd:nil didReward:nil instanceId:placementID];
    }
    if ([info.didDownload boolValue]) {
        [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter didClickInterstitialAd:nil instanceId:placementID];
    }
    [self.vungleVideoAdapter.delegate adapter:self.vungleVideoAdapter didCloseVideoAd:nil instanceId:placementID];
    [self.vungleInterstitialAdapter.delegate adapter:self.vungleInterstitialAdapter willDismissScreen:nil instanceId:placementID];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
}

@end
