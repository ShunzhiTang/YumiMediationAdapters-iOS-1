//
//  YumiMediationInterstitialAdapterIronSource.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/10.
//

#import "YumiMediationInterstitialAdapterIronSource.h"
#import <IronSource/IronSource.h>

@interface YumiMediationInterstitialAdapterIronSource () <ISDemandOnlyInterstitialDelegate>
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

    [IronSource setISDemandOnlyInterstitialDelegate:self];
    if (self.provider.data.key1.length == 0) {
        [self.delegate adapter:self interstitialAd:nil didFailToReceive:@"No app id specified"];
        return self;
    }
    [IronSource initISDemandOnly:self.provider.data.key1 adUnits:@[IS_INTERSTITIAL]];
    [IronSource loadISDemandOnlyInterstitial:self.provider.data.key2];
    return self;
}

- (void)requestAd {
    [IronSource loadInterstitial];
}

- (BOOL)isReady {
    return [IronSource hasISDemandOnlyInterstitial:self.provider.data.key2];
    ;
}

- (void)present {
    [IronSource showISDemandOnlyInterstitial:[self.delegate rootViewControllerForPresentingModalView] instanceId:self.provider.data.key2];
}

#pragma mark - ISDemandOnlyInterstitialDelegate
/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad:(NSString *)instanceId{
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}

/**
 Called after an interstitial has attempted to load but failed.
 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId{
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:[error localizedDescription]];
}

/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen:(NSString *)instanceId{
    [self.delegate adapter:self willPresentScreen:nil];
}

/**
 Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose:(NSString *)instanceId{
    [self.delegate adapter:self willDismissScreen:nil];
}

/**
 Called after an interstitial has been displayed on the screen.
 */
- (void)interstitialDidShow:(NSString *)instanceId{
}

/**
 Called after an interstitial has attempted to show but failed.
 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId{
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:[error localizedDescription]];
}

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial:(NSString *)instanceId{
    [self.delegate adapter:self didClickInterstitialAd:nil];
}

@end
