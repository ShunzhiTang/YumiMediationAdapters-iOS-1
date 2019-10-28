//
//  YumiMediationInterstitialAdapterPubNative.m
//  Pods
//
//  Created by generator on 13/08/2019.
//
//

#import "YumiMediationInterstitialAdapterPubNative.h"
#import <HyBid/HyBid.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterPubNative () <HyBidInterstitialAdDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;

@property (nonatomic, assign) BOOL isInitSDKSuccess;

@end

@implementation YumiMediationInterstitialAdapterPubNative

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDPubNative
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    return self;
}

- (NSString *)networkVersion {
    return @"1.3.7";
}

- (void)requestAd {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        // Call this to let PubNative know the user has granted consent
        [[HyBidUserDataManager sharedInstance] grantConsent];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        // Call this to let PubNative know the user has revoked consent
        [[HyBidUserDataManager sharedInstance] denyConsent];
    }
    
    if (self.isInitSDKSuccess) {
        [self loadAd];
        return;
    }
    
   // init sdk
    __weak typeof(self) weakSelf = self;
   [[YumiLogger stdLogger] debug:@"---PubNative init SDK"];
   [HyBid initWithAppToken:self.provider.data.key1 completion:^(BOOL success) {
       weakSelf.isInitSDKSuccess = success;
       if (success) {
           [[YumiLogger stdLogger] debug:@"---PubNative init completion"];
           [weakSelf loadAd];
           return ;
       }
       [[YumiLogger stdLogger] debug:@"---PubNative init fail"];
       [weakSelf.delegate coreAdapter:weakSelf coreAd:nil didFailToLoad:@"PubNative init fail" adType:weakSelf.adType];
   }];
    
}

- (void)loadAd{
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:self.provider.data.key2 andWithDelegate:self];
    [self.interstitialAd load];
    [[YumiLogger stdLogger] debug:@"---PubNative start request ad"];
}

- (BOOL)isReady {

    return [self.interstitialAd isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---PubNative present"];
    [self.interstitialAd show];
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

#pragma mark : HyBidInterstitialAdDelegate
- (void)interstitialDidLoad {
    [self.delegate coreAdapter:self didReceivedCoreAd:self.interstitialAd adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---PubNative did load"];
}
- (void)interstitialDidFailWithError:(NSError *)error {
    [self.delegate coreAdapter:self
                        coreAd:self.interstitialAd
                 didFailToLoad:error.localizedDescription
                        adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---PubNative did fail"];
}
- (void)interstitialDidTrackImpression {
    [self.delegate coreAdapter:self didOpenCoreAd:self.interstitialAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.interstitialAd adType:self.adType];
}
- (void)interstitialDidTrackClick {
    [self.delegate coreAdapter:self didClickCoreAd:self.interstitialAd adType:self.adType];
}
- (void)interstitialDidDismiss {
    [self.delegate coreAdapter:self didCloseCoreAd:self.interstitialAd isCompletePlaying:NO adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---PubNative did close"];
    
    self.interstitialAd = nil;
}

@end
