//
//  YumiMediationVideoAdapterIronSource.m
//  Pods
//
//  Created by generator on 26/06/2017.
//
//

#import "YumiMediationVideoAdapterIronSource.h"
#import "IronSource/IronSource.h"

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

    NSString *userId = [IronSource advertiserId];
    if ([userId length] == 0) {
        // If we couldn't get the advertiser id, we will use a default one.
        userId = @"YumiMobi";
    }
    // After setting the delegates you can go ahead and initialize the SDK.
    [IronSource setUserId:userId];
    [IronSource setRewardedVideoDelegate:self];
    [IronSource initWithAppKey:provider.data.key1];
    
    return self;
}

- (void)requestAd {
    // NOTE: Unity do not provide any method for requesting ad, it handles the request internally
}

- (BOOL)isReady {
    return [IronSource hasRewardedVideo];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [IronSource showRewardedVideoWithViewController:rootViewController];
}

#pragma mark - ISRewardedVideoDelegate

- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    if (available) {
        [self.delegate adapter:self didReceiveVideoAd:nil];
    }
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    self.isReward = YES;
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription]];
}

- (void)rewardedVideoDidOpen {
    [self.delegate adapter:self didOpenVideoAd:nil];
}

- (void)rewardedVideoDidClose {

    if (self.isReward) {
        [self.delegate adapter:self videoAd:nil didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:nil];
}

- (void)rewardedVideoDidStart {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)rewardedVideoDidEnd {
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
}

@end
