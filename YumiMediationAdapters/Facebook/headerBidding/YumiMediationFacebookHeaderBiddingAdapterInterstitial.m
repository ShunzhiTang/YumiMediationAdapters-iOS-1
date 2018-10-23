//
//  YumiMediationFacebookHeaderBiddingAdapterInterstitial.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/9/18.
//

#import "YumiMediationFacebookHeaderBiddingAdapterInterstitial.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBInterstitialAd.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationFacebookHeaderBiddingAdapterInterstitial () <YumiMediationInterstitialAdapter,
                                                                     FBInterstitialAdDelegate>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;
@property (nonatomic) FBInterstitialAd *interstitial;

@end

@implementation YumiMediationFacebookHeaderBiddingAdapterInterstitial

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebookHeaderBidding
                                                             requestType:YumiMediationSDKAdRequest];
    NSString *key =
        [NSString stringWithFormat:@"%@_%lu_%@", kYumiMediationAdapterIDFacebookHeaderBidding,
                                   (unsigned long)YumiMediationAdTypeInterstitial, YumiMediationHeaderBiddingToken];
    [[NSUserDefaults standardUserDefaults] setObject:FBAdSettings.bidderToken ?: @"" forKey:key];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.provider.data.key1];
    self.interstitial.delegate = self;

    return self;
}

- (void)requestAd {
    if (self.provider.data.payload.length == 0) {
        [self.delegate adapter:self interstitialAd:nil didFailToReceive:self.provider.data.errMessage];
        return;
    }
    [self.interstitial loadAdWithBidPayload:self.provider.data.payload];
}

- (BOOL)isReady {
    return self.interstitial.adValid;
}

- (void)present {
    [self.interstitial showAdFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:interstitialAd didFailToReceive:[error localizedDescription]];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self didClickInterstitialAd:interstitialAd];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate adapter:self willDismissScreen:interstitialAd];
}

@end
