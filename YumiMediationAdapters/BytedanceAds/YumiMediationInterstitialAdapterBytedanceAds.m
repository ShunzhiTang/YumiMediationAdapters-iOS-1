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

@interface YumiMediationInterstitialAdapterBytedanceAds ()<BUInterstitialAdDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) BUInterstitialAd *interstitialAd;

@end

@implementation YumiMediationInterstitialAdapterBytedanceAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDBytedanceAds
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    [BUAdSDKManager setAppID:self.provider.data.key1];
    
    self.interstitialAd = [[BUInterstitialAd alloc] initWithSlotID:self.provider.data.key2 size:[BUSize sizeBy:BUProposalSize_Interstitial600_600]];
    self.interstitialAd.delegate = self;
    
    return self;
}

- (void)requestAd {
   
    [self.interstitialAd loadAdData];
}

- (BOOL)isReady {
    
    return self.interstitialAd.isAdValid;
}

- (void)present {
    [self.interstitialAd showAdFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark: BUInterstitialAdDelegate
- (void)interstitialAdDidLoad:(BUInterstitialAd *)interstitialAd{
    [self.delegate adapter:self didReceiveInterstitialAd:interstitialAd];
}

- (void)interstitialAd:(BUInterstitialAd *)interstitialAd didFailWithError:(NSError *)error{
   [self.delegate adapter:self interstitialAd:interstitialAd didFailToReceive:[error localizedDescription]];
}

- (void)interstitialAdWillVisible:(BUInterstitialAd *)interstitialAd{

}

- (void)interstitialAdDidClick:(BUInterstitialAd *)interstitialAd{
    [self.delegate adapter:self didClickInterstitialAd:interstitialAd];
}

- (void)interstitialAdDidClose:(BUInterstitialAd *)interstitialAd{
   [self.delegate adapter:self willDismissScreen:interstitialAd];
}

@end
