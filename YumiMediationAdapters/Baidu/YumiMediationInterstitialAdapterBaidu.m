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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.interstitial load];
    });
}

- (BOOL)isReady {
    return [self.interstitial isReady];
}

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self didReceiveInterstitialAd:interstitial];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self interstitialAd:interstitial didFailToReceive:@"Baidu ad load fail"];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self willPresentScreen:interstitial];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self willDismissScreen:interstitial];
}

@end
