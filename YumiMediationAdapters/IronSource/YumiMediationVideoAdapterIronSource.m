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

@end

@implementation YumiMediationVideoAdapterIronSource

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDIronsource
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
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
    // NOTE: reward user in didClose delegate
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:nil didFailToLoad:[error localizedDescription]];
}

- (void)rewardedVideoDidOpen {
    [self.delegate adapter:self didOpenVideoAd:nil];
}

- (void)rewardedVideoDidClose {
    [self.delegate adapter:self didCloseVideoAd:nil];

    // NOTE: in case didReceiveRewardForPlacement not executed
    [self.delegate adapter:self videoAd:nil didReward:nil];
}

- (void)rewardedVideoDidStart {
    [self.delegate adapter:self didStartPlayingVideoAd:nil];
}

- (void)rewardedVideoDidEnd {
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo{
}

@end
