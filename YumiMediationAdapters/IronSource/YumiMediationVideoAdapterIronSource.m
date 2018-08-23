//
//  YumiMediationVideoAdapterIronSource.m
//  Pods
//
//  Created by generator on 26/06/2017.
//
//

#import "YumiMediationVideoAdapterIronSource.h"
#import <IronSource/IronSource.h>

@interface YumiMediationVideoAdapterIronSource () <ISRewardedVideoDelegate>
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

    [IronSource setRewardedVideoDelegate:self];
    if (self.provider.data.key1.length == 0) {
        [self.delegate adapter:self videoAd:nil didFailToLoad:@"No app id specified"];
        return self;
    }
    [IronSource initWithAppKey:self.provider.data.key1 adUnits:@[ IS_REWARDED_VIDEO ]];
    return self;
}

- (void)requestAd {
    // NOTE: ironsource do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [IronSource hasRewardedVideo];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [IronSource showRewardedVideoWithViewController:rootViewController];
}

#pragma mark - ISRewardedVideoDelegate
// Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available //and ready to be shown, NO otherwise.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    if (available) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    }
}

// Called after a rewarded video has been viewed completely and the user is //eligible for reward.@param placementInfo
// An object that contains the //placement's reward name and amount.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    self.isReward = YES;
    [self.delegate adapter:self videoAd:nil didReward:nil];
}

// Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription]];
}

// Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen {
    [self.delegate adapter:self didOpenVideoAd:nil];
}

// Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose {
    if (!self.isReward) {
        [self.delegate adapter:self videoAd:nil didReward:nil];
    }
    self.isReward = NO;
    [self.delegate adapter:self didCloseVideoAd:nil];
}

// Note: the events below are not available for all supported rewarded video ad networks. Check which events are
// available per ad network you choose //to include in your build.  We recommend only using events which register to ALL
// ad networks you //include in your build.  Called after a rewarded video has started playing.
- (void)rewardedVideoDidStart {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

// Called after a rewarded video has finished playing.
- (void)rewardedVideoDidEnd {
}

/**
 Called after a video has been clicked.
 */
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
}
@end
