//
//  YumiMediationInterstitialAdapterBaidu.m
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import "YumiMediationInterstitialAdapterBaidu.h"
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>

@interface YumiMediationInterstitialAdapterBaidu () <BaiduMobAdInterstitialDelegate>

@property (nonatomic) BaiduMobAdInterstitial *interstitial;

@end

@implementation YumiMediationInterstitialAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDBaidu
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    self.interstitial = [[BaiduMobAdInterstitial alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.AdUnitTag = self.provider.data.key2;
    self.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;

    return self;
}

- (void)requestAd {
    [self.interstitial load];
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self interstitialAd:interstitial didFailToReceive:@"Baidu ad load fail"];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self willPresentScreen:interstitial];
}

- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial {
}
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason {
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
}

- (void)interstitialDidDismissLandingPage:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self willDismissScreen:interstitial];
}


@end
