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

@end

@implementation YumiMediationInterstitialAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDAdMob
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

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

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self.delegate adapter:self didReceiveInterstitialAd:ad];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.delegate adapter:self interstitialAd:ad didFailToReceive:[error localizedDescription]];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [self.delegate adapter:self willDismissScreen:ad];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self.delegate adapter:self didClickInterstitialAd:ad];
}

@end
