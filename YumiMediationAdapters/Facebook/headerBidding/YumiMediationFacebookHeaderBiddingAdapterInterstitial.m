//
//  YumiMediationFacebookHeaderBiddingAdapterInterstitial.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/9/18.
//

#import "YumiMediationFacebookHeaderBiddingAdapterInterstitial.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <FBAudienceNetwork/FBInterstitialAd.h>
#import <FBAudienceNetwork/FBAdSettings.h>

@interface YumiMediationFacebookHeaderBiddingAdapterInterstitial ()<YumiMediationInterstitialAdapter,FBInterstitialAdDelegate>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;
@property (nonatomic) FBInterstitialAd *interstitial;
@property (nonatomic) NSString *bidPayloadFromServer;

@end

@implementation YumiMediationFacebookHeaderBiddingAdapterInterstitial

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebookHeaderBidding
                                                             requestType:YumiMediationSDKAdRequest];
}

- (void)setUpBidPayloadValue:(NSString *)bidPayload{
    self.bidPayloadFromServer = bidPayload;
}

- (NSString *)fetchFacebookBidderToken{
    return FBAdSettings.bidderToken ? : @"";
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
    [self.interstitial loadAdWithBidPayload:self.bidPayloadFromServer];
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
