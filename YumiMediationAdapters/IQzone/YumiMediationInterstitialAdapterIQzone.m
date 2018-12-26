//
//  YumiMediationInterstitialAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationInterstitialAdapterIQzone.h"
#import <IMDSDK.h>
#import <IMDInterstitialViewController.h>

@interface YumiMediationInterstitialAdapterIQzone ()<IMDInterstitialViewDelegate>

@property (nonatomic) IMDInterstitialViewController *interstitial;
@property (nonatomic , assign) BOOL isInterstitialReady;

@end

@implementation YumiMediationInterstitialAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDIQzone
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    // TODO: setup code
    self.interstitial = [IMDSDK newInterstitialViewController:[self.delegate rootViewControllerForPresentingModalView] placementID:self.provider.data.key1 loadedListener:self andMetadata:nil];
    
    return self;
}

- (void)requestAd {
    self.isInterstitialReady = NO;
    [self.interstitial load];
}

- (BOOL)isReady {
    
    return self.isInterstitialReady;
}

- (void)present {
   
    [self.interstitial show:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark: -IMDInterstitialViewDelegate

- (void)adLoaded {
    self.isInterstitialReady = YES;
    
    [self.delegate adapter:self didReceiveInterstitialAd:self.interstitial];
}

- (void)adClicked {
    [self.delegate adapter:self didClickInterstitialAd:self.interstitial];
}
- (void)adFailedToLoad {
    self.isInterstitialReady = NO;
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:@"interstitial load fail"];
}

- (void)adImpression {
    [self.delegate adapter:self willPresentScreen:self.interstitial];
}

- (void)adDismissed {
    [self.delegate adapter:self willDismissScreen:self.interstitial];
}

- (void)adExpanded {
    
}

- (void)videoCompleted {
    
}

- (void)videoSkipped {
    
}

- (void)videoStarted {
    
}

- (void)videoTrackerFired {
    
}

@end
