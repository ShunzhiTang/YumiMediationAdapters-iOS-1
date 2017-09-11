//
//  YumiMediationVideoAdapterPlayableAds.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterPlayableAds.h"
#import <PlayableAds/PlayableAds.h>

@interface YumiMediationVideoAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *video;

@end

@implementation YumiMediationVideoAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDPlayableAds
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
}

- (void)requestAd {
    self.video = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2
                                                 appID:self.provider.data.key1
                                    rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    self.video.delegate = self;
    [self.video loadAd];
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video present];
}

#pragma mark - PlayableAdsDelegate

- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
    // NOTE: reward user in didClose delegate
}

- (void)playableAdsDidLoad:(PlayableAds *)ads {
    [self.delegate adapter:self didReceiveVideoAd:self.video];
}

- (void)playableAdsDidFailToLoadWithError:(NSError *)error {
    [self.delegate adapter:self videoAd:self.video didFailToLoad:[error localizedDescription]];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate adapter:self didStartPlayingVideoAd:self.video];
}

- (void)playableAdsDidPresentScreen:(PlayableAds *)ads {
    [self.delegate adapter:self didOpenVideoAd:self.video];
}

- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    [self.delegate adapter:self didCloseVideoAd:self.video];
    // NOTE: in case didReceiveRewardForPlacement not executed
    [self.delegate adapter:self videoAd:self.video didReward:nil];
}

@end
