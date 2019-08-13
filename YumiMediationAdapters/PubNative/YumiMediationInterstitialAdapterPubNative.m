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

@interface YumiMediationInterstitialAdapterPubNative ()

@property (nonatomic, assign) YumiMediationAdType adType;

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

    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        // Call this to let PubNative know the user has granted consent
        [[HyBidUserDataManager sharedInstance] grantConsent];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        // Call this to let PubNative know the user has revoked consent
        [[HyBidUserDataManager sharedInstance] denyConsent];
    }
    // init sdk
    [HyBid initWithAppToken:self.provider.data.key1 completion:^(BOOL success) {
        if (success) {
            /// ...
        }
    }];

    return self;
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
    
}

- (BOOL)isReady {
    // TODO: check if ready
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // TODO: present video ad
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

@end
