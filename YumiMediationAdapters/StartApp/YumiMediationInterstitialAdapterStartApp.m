//
//  YumiMediationInterstitialAdapterStartApp.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterStartApp.h"
#import <StartApp/StartApp.h>

@interface YumiMediationInterstitialAdapterStartApp () <STADelegateProtocol>

@property (nonatomic) STAStartAppAd *interstitial;

@end

@implementation YumiMediationInterstitialAdapterStartApp

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDStartApp
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = self.provider.data.key1;

    self.interstitial = [[STAStartAppAd alloc] init];

    return self;
}

- (void)requestAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.interstitial loadAdWithDelegate:self];
    });
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial showAd];
}

#pragma mark - STADelegateProtocol
- (void)didLoadAd:(STAAbstractAd *)ad {
    [self.delegate adapter:self didReceiveInterstitialAd:ad];
}

- (void)failedLoadAd:(STAAbstractAd *)ad withError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:ad didFailToReceive:[error localizedDescription]];
}

- (void)didCloseAd:(STAAbstractAd *)ad {
    [self.delegate adapter:self willDismissScreen:ad];
}

- (void)didClickAd:(STAAbstractAd *)ad {
    [self.delegate adapter:self didClickInterstitialAd:ad];
}

@end
