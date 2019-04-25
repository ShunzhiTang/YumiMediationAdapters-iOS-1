//
//  YumiMediationInterstitialAdapterGDT.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterGDT.h"
#import "GDTMobInterstitial.h"

@interface YumiMediationInterstitialAdapterGDT () <GDTMobInterstitialDelegate>

@property (nonatomic) GDTMobInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterGDT

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDGDT
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.interstitial = [[GDTMobInterstitial alloc] initWithAppId:weakSelf.provider.data.key1 ?: @""
                                                              placementId:weakSelf.provider.data.key2 ?: @""];
        weakSelf.interstitial.delegate = weakSelf;
    });

    return self;
}

- (void)requestAd {
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

#pragma mark - GDTMobInterstitialDelegate
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:[error localizedDescription] adType:self.adType];
}

- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:NO adType:self.adType];
}

- (void)interstitialClicked:(GDTMobInterstitial *)interstitial {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

@end
