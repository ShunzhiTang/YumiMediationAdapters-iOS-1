//
//  YumiMediationInterstitialAdapterGDT.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterGDT.h"
#import "GDTUnifiedInterstitialAd.h"
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterGDT () <GDTUnifiedInterstitialAdDelegate>

@property (nonatomic) GDTUnifiedInterstitialAd *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterGDT
- (NSString *)networkVersion {
    return @"4.10.13";
}

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

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---GDT interstitial start request"];
    self.interstitial = [[GDTUnifiedInterstitialAd alloc] initWithAppId:self.provider.data.key1 ?: @""
                                                            placementId:self.provider.data.key2 ?: @""];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (BOOL)isReady {
    [[YumiLogger stdLogger] debug:[NSString stringWithFormat:@"---GDT interstitial cheack ready status.%d",[self.interstitial isAdValid]]];
    return [self.interstitial isAdValid];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---GDT interstitial present"];
    [self.interstitial presentAdFromRootViewController:rootViewController];
}

#pragma mark - GDTUnifiedInterstitialAdDelegate

- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [[YumiLogger stdLogger] debug:@"---GDT interstitial did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:unifiedInterstitial adType:self.adType];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [[YumiLogger stdLogger] debug:@"---GDT interstitial did fail to load"];
    [self.delegate coreAdapter:self
                        coreAd:unifiedInterstitial
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
}

- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:unifiedInterstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:unifiedInterstitial adType:self.adType];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate coreAdapter:self didClickCoreAd:unifiedInterstitial adType:self.adType];
}

- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [[YumiLogger stdLogger] debug:@"---GDT interstitial did closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:unifiedInterstitial isCompletePlaying:NO adType:self.adType];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
}

@end
