//
//  YumiMediationVungleInstance.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import "YumiMediationVungleInstance.h"

@interface YumiMediationVungleInstance ()

@property (nonatomic,copy)VungleInitializeBlock initBlock;

@end

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

#pragma mark: private method
- (void)vungleSDKDidInitializeCompleted:(VungleInitializeBlock)completed {
    self.initBlock = completed;
}

#pragma mark : -- VungleSDKDelegate
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(nullable NSString *)placementID
                            error:(nullable NSError *)error {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID] && isAdPlayable) {
            [[YumiLogger stdLogger] debug:@"---Vungle video did load "];
            [videoAdapter.delegate coreAdapter:videoAdapter didReceivedCoreAd:nil adType:YumiMediationAdTypeVideo];
        } else if ([videoAdapter.provider.data.key2 isEqualToString:placementID] && !isAdPlayable) {
            [[YumiLogger stdLogger] debug:@"---Vungle video did fail "];
            [videoAdapter.delegate coreAdapter:videoAdapter
                                        coreAd:nil
                                 didFailToLoad:@"vungle is no fill"
                                        adType:YumiMediationAdTypeVideo];
        }
    }

    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && isAdPlayable) {
            [[YumiLogger stdLogger] debug:@"---Vungle interstitial did load "];
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                    didReceivedCoreAd:nil
                                               adType:YumiMediationAdTypeInterstitial];
        } else if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID] && !isAdPlayable) {
            [[YumiLogger stdLogger] debug:@"---Vungle interstitial did fail "];
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                               coreAd:nil
                                        didFailToLoad:@"vungle is no fill"
                                               adType:YumiMediationAdTypeInterstitial];
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    for (YumiMediationVideoAdapterVungle *videoAdapter in self.vungleVideoAdapters) {
        if ([videoAdapter.provider.data.key2 isEqualToString:placementID]) {
            [videoAdapter.delegate coreAdapter:videoAdapter didOpenCoreAd:nil adType:YumiMediationAdTypeVideo];
            [videoAdapter.delegate coreAdapter:videoAdapter didStartPlayingAd:nil adType:YumiMediationAdTypeVideo];
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                        didOpenCoreAd:nil
                                               adType:YumiMediationAdTypeInterstitial];
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                    didStartPlayingAd:nil
                                               adType:YumiMediationAdTypeInterstitial];
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
            // click
            if ([info.didDownload boolValue]) {
                [videoAdapter.delegate coreAdapter:videoAdapter didClickCoreAd:nil adType:YumiMediationAdTypeVideo];
            }
            // reward
            if ([info.completedView boolValue]) {
                [[YumiLogger stdLogger] debug:@"---Vungle video did reward "];
                [videoAdapter.delegate coreAdapter:videoAdapter
                                            coreAd:nil
                                         didReward:YES
                                            adType:YumiMediationAdTypeVideo];
            }
            [[YumiLogger stdLogger] debug:@"---Vungle video did close "];
            [videoAdapter.delegate coreAdapter:videoAdapter
                                didCloseCoreAd:nil
                             isCompletePlaying:[info.completedView boolValue]
                                        adType:YumiMediationAdTypeVideo];
        }
    }
    for (YumiMediationInterstitialAdapterVungle *interstitialAdapter in self.vungleInterstitialAdapters) {
        if ([interstitialAdapter.provider.data.key3 isEqualToString:placementID]) {
            if ([info.didDownload boolValue]) {
                [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                           didClickCoreAd:nil
                                                   adType:YumiMediationAdTypeInterstitial];
            }
            [[YumiLogger stdLogger] debug:@"---Vungle interstitial did close "];
            [interstitialAdapter.delegate coreAdapter:interstitialAdapter
                                       didCloseCoreAd:nil
                                    isCompletePlaying:NO
                                               adType:YumiMediationAdTypeInterstitial];
        }
    }
}
#pragma mark: vungle init callback
- (void)vungleSDKDidInitialize {
    if (self.initBlock) {
        self.initBlock(YES);
    }
}
- (void)vungleSDKFailedToInitializeWithError:(NSError *)error  {
    if (self.initBlock) {
        self.initBlock(NO);
    }
}
@end
