//
//  YumiMediationInterstitialAdapterBytedanceAds.m
//  Pods
//
//  Created by generator on 23/05/2019.
//
//

#import "YumiMediationInterstitialAdapterBytedanceAds.h"
#import <BUAdSDK/BUAdSDK.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterBytedanceAds () <BUInterstitialAdDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) BUInterstitialAd *interstitialAd;

@end

@implementation YumiMediationInterstitialAdapterBytedanceAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBytedanceAds
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    [BUAdSDKManager setAppID:self.provider.data.key1];

    self.interstitialAd = [[BUInterstitialAd alloc] initWithSlotID:self.provider.data.key2
                                                              size:[BUSize sizeBy:BUProposalSize_Interstitial600_600]];
    self.interstitialAd.delegate = self;

    return self;
}

- (NSString *)networkVersion {
    return @"2.0.1.1";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {

    [self.interstitialAd loadAdData];
}

- (BOOL)isReady {

    return self.interstitialAd.isAdValid;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitialAd showAdFromRootViewController:rootViewController];
}

#pragma mark : BUInterstitialAdDelegate
- (void)interstitialAdDidLoad:(BUInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAd:(BUInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:interstitialAd didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)interstitialAdWillVisible:(BUInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitialAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitialAd adType:self.adType];
}

- (void)interstitialAdDidClick:(BUInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didClickCoreAd:interstitialAd adType:self.adType];
}

- (void)interstitialAdDidClose:(BUInterstitialAd *)interstitialAd {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitialAd isCompletePlaying:NO adType:self.adType];
}

@end
