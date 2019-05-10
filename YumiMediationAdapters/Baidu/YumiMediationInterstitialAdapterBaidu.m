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
@property (nonatomic, assign) BOOL interstitialIsReady;

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
    self.interstitialIsReady = NO;

    return self;
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.interstitial = [[BaiduMobAdInterstitial alloc] init];
        weakSelf.interstitial.delegate = weakSelf;
        weakSelf.interstitial.AdUnitTag = weakSelf.provider.data.key2;
        weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
        [weakSelf.interstitial load];
    });
}

- (BOOL)isReady {
    return self.interstitialIsReady;
}

- (void)present {
    [self.interstitial presentFromRootViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = YES;
    [self.delegate adapter:self didReceiveInterstitialAd:interstitial];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = NO;
    [self.delegate adapter:self interstitialAd:interstitial didFailToReceive:@"Baidu ad load fail"];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = NO;
    [self.delegate adapter:self willPresentScreen:interstitial];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self didClickInterstitialAd:interstitial];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate adapter:self willDismissScreen:interstitial];
    self.interstitial = nil;
    self.interstitialIsReady = NO;
}

- (void)dealloc {
    self.interstitial.delegate = nil;
}

@end
