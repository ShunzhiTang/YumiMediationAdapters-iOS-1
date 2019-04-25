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
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBaidu
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                                delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType{
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

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

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:@"Baidu ad load fail" adType:self.adType];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason {
    [self.delegate coreAdapter:self failedToShowAd:interstitial errorString:@"Baidu ad failed to show" adType:self.adType];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:NO adType:self.adType];
}

- (void)dealloc {
    self.interstitial.delegate = nil;
}

@end
