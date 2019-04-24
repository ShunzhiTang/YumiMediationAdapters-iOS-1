//
//  YumiMediationInterstitialAdapterAdMob.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationInterstitialAdapterAdMob () <GADInterstitialDelegate>

@property (nonatomic) GADInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAdMob
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        return self;
    }
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
    }];
    return self;
}

- (void)requestAd {
    //  Only one interstitial request is allowed at a time.
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.provider.data.key1];
    self.interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate coreAdapter:self coreAd:ad didFailToLoad:[error localizedDescription] adType:self.adType];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:NO adType:self.adType];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

@end
