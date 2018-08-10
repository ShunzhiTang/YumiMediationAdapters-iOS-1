//
//  YumiMediationInterstitialAdapterPlayableAds.m
//  Pods
//
//  Created by generator on 22/01/2018.
//
//

#import "YumiMediationInterstitialAdapterPlayableAds.h"
#import <PlayableAds/PlayableAds.h>

@interface YumiMediationInterstitialAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *interstitial;

@end

@implementation YumiMediationInterstitialAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDPlayableAds
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)requestAd {
    // TODO: request ad
    self.interstitial = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
    self.interstitial.autoLoad = NO;
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    // TODO: check if ready
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial present];
}

#pragma mark : -- PlayableAdsDelegate
- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
}
- (void)playableAdsDidLoad:(PlayableAds *)ads {
    [self.delegate adapter:self didReceiveInterstitialAd:ads];
}
- (void)playableAds:(PlayableAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:ads didFailToReceive:[error localizedDescription]];
}
- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    [self.delegate adapter:self willDismissScreen:ads];
}

- (void)playableAdsDidClick:(PlayableAds *)ads {
    [self.delegate adapter:self didClickInterstitialAd:ads];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate adapter:self willPresentScreen:ads];
}

@end
