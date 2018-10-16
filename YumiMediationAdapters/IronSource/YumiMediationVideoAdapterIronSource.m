//
//  YumiMediationVideoAdapterIronSource.m
//  Pods
//
//  Created by generator on 26/06/2017.
//
//

#import "YumiMediationVideoAdapterIronSource.h"
#import <IronSource/IronSource.h>

@interface YumiMediationVideoAdapterIronSource () <ISDemandOnlyRewardedVideoDelegate>
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterIronSource

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDIronsource
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [IronSource setISDemandOnlyRewardedVideoDelegate:self];
    [IronSource shouldTrackReachability:YES];
    if (self.provider.data.key1.length == 0 || self.provider.data.key2.length == 0) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"No app id or instance id specified"];
        return nil;
    }
    [IronSource initISDemandOnly:self.provider.data.key1 adUnits:@[ IS_REWARDED_VIDEO ]];
    return self;
}

- (void)requestAd {
    // NOTE: ironsource do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [IronSource hasISDemandOnlyRewardedVideo:self.provider.data.key2];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [IronSource showISDemandOnlyRewardedVideo:rootViewController instanceId:self.provider.data.key2];
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate
// Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available and ready to be shown, NO otherwise.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available instanceId:(NSString *)instanceId {
    if (available) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    } else {
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"ironSource is not available" isRetry:NO];
    }
}

// Called after a rewarded video has been viewed completely and the user is eligible for reward.
//@param placementInfo An object that contains the placement's reward name and amount.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
    self.isReward = YES;
    [self.delegate adapter:self videoAd:nil didReward:nil instanceId:instanceId];
}

// Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription] isRetry:NO];
}

// Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [self.delegate adapter:self didOpenVideoAd:nil];
}

// Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose:(NSString *)instanceId {
    if (!self.isReward) { // ironsource 确保无中途关闭并且奖励回调始终在关闭之前
        [self.delegate adapter:self videoAd:nil didReward:nil instanceId:instanceId];
    }
    self.isReward = NO;
    [self.delegate adapter:self didCloseVideoAd:nil instanceId:instanceId];
}

// Invoked when the end user clicked on the RewardedVideo ad
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
}

@end
