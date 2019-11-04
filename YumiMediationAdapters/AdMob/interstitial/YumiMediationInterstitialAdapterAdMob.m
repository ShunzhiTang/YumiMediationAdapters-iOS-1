//
//  YumiMediationInterstitialAdapterAdMob.m
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import "YumiMediationInterstitialAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterAdMob () <GADInterstitialDelegate>

@property (nonatomic) GADInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterAdMob
- (NSString *)networkVersion {
    return @"7.50.0";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAdMob
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:YumiMediationAdmobAdapterUUID];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];
    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;
    
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    GADExtras *extras = [[GADExtras alloc] init];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        extras.additionalParameters = @{@"npa" : @"0"};
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        extras.additionalParameters = @{@"npa" : @"1"};
    }
    GADRequest *request = [GADRequest request];
    [request registerAdNetworkExtras:extras];

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        //  Only one interstitial request is allowed at a time.
        [[YumiLogger stdLogger] debug:@"---Admob start request"];
        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.provider.data.key1];
        self.interstitial.delegate = self;
        [self.interstitial loadRequest:request];
        return;
    }
    [[YumiLogger stdLogger] debug:@"---Admob init"];
    __weak __typeof(self)weakSelf = self;
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [[YumiLogger stdLogger] debug:@"---Admob configured"];
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
        //  Only one interstitial request is allowed at a time.
        [[YumiLogger stdLogger] debug:@"---Admob start request"];
        weakSelf.interstitial = [[GADInterstitial alloc] initWithAdUnitID:weakSelf.provider.data.key1];
        weakSelf.interstitial.delegate = weakSelf;
        [weakSelf.interstitial loadRequest:request];
    }];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---Admob check ready status.%d",[self.interstitial isReady]];
    [[YumiLogger stdLogger] debug:msg];
    return [self.interstitial isReady];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Admob present"];
    [self.interstitial presentFromRootViewController:rootViewController];
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [[YumiLogger stdLogger] debug:@"---Admob did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:ad adType:self.adType];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [[YumiLogger stdLogger] debug:@"---Admob did fail to load"];
    [self.delegate coreAdapter:self coreAd:ad didFailToLoad:[error localizedDescription] adType:self.adType];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didOpenCoreAd:ad adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ad adType:self.adType];
}

/// Called when |ad| fails to present.
- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self failedToShowAd:ad errorString:@"admob did fail to show ad" adType:self.adType];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [[YumiLogger stdLogger] debug:@"---Admob is closed"];
    [self.delegate coreAdapter:self didCloseCoreAd:ad isCompletePlaying:NO adType:self.adType];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self.delegate coreAdapter:self didClickCoreAd:ad adType:self.adType];
}

@end
