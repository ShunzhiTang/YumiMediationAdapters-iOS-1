//
//  YumiMediationInterstitialAdapterIronSource.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/10.
//

#import "YumiMediationInterstitialAdapterIronSource.h"
#import <IronSource/IronSource.h>

@interface YumiMediationInterstitialAdapterIronSource () <ISInterstitialDelegate>
@end

@implementation YumiMediationInterstitialAdapterIronSource

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDIronsource
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    [IronSource setInterstitialDelegate:self];
    if (self.provider.data.key1.length == 0) {
        [self.delegate adapter:self interstitialAd:nil didFailToReceive:@"No app id specified"];
        return self;
    }
    [IronSource initWithAppKey:self.provider.data.key1 adUnits:@[ IS_INTERSTITIAL ]];

    return self;
}

- (void)requestAd {
    [IronSource loadInterstitial];
}

- (BOOL)isReady {
    return [IronSource hasInterstitial];
    ;
}

- (void)present {
    [IronSource showInterstitialWithViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - ISInterstitialDelegate
/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad {
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}

/**
 Called after an interstitial has attempted to load but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:[error localizedDescription]];
}

/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen {
    [self.delegate adapter:self willPresentScreen:nil];
}

/**
 Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose {
    [self.delegate adapter:self willDismissScreen:nil];
}

/**
 Called after an interstitial has been displayed on the screen.
 */
- (void)interstitialDidShow {
}

/**
 Called after an interstitial has attempted to show but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error {
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:[error localizedDescription]];
}

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial {
    [self.delegate adapter:self didClickInterstitialAd:nil];
}

@end
