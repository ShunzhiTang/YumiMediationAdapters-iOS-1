//
//  YumiMediationInterstitialAdapterNativeAdMob.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import "YumiMediationInterstitialAdapterNativeAdMob.h"
#import <GoogleMobileAds/GADNativeAdViewAdOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface YumiMediationInterstitialAdapterNativeAdMob()<GADNativeAppInstallAdLoaderDelegate, GADAdLoaderDelegate,GADNativeAdDelegate>

@property (nonatomic) GADAdLoader *adLoader;
@property (nonatomic)  GADNativeAppInstallAdView *appInstallAdView;
@property (nonatomic,assign) BOOL isAdReady;

@end

@implementation YumiMediationInterstitialAdapterNativeAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDAdmobNative
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark: YumiMediationInterstitialAdapter

- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate{
    self  = [super init];
    
    self.provider = provider;
    self.delegate = delegate;
    
    return self;
}

- (void)requestAd {
    GADNativeAdViewAdOptions *option = [[GADNativeAdViewAdOptions alloc] init];
    option.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:self.provider.data.key1 rootViewController:nil adTypes:adTypes options:@[option]];
    
    GADRequest *request = [GADRequest request];
    
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:request];
}

- (BOOL)isReady {
    
    return self.isAdReady;
}

- (void)present{
    
}

#pragma mark: - GADAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error{
    self.isAdReady = NO;
    [self.delegate adapter:self interstitialAd:adLoader didFailToReceive:[error localizedDescription]];
}

#pragma mark: - GADNativeAppInstallAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader
didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd{
    self.isAdReady = YES;
}

#pragma mark: - GADNativeAdDelegate
- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd{
    
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd{

}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd{
    
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd{
    
}

@end
