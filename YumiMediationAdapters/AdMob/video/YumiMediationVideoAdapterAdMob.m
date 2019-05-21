//
//  YumiMediationVideoAdapterAdMob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterAdMob () <GADRewardBasedVideoAdDelegate>
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAdMob
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:YumiMediationAdmobAdapterUUID];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:YumiMediationAdmobAdapterUUID]) {
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        return self;
    }
    __weak __typeof(self)weakSelf = self;
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
        [GADRewardBasedVideoAd sharedInstance].delegate = weakSelf;
    }];

    
    return self;
}

- (void)requestAd {
    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    
    GADExtras *extras = [[GADExtras alloc] init];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        extras.additionalParameters = @{@"npa": @"0"};
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        extras.additionalParameters = @{@"npa": @"1"};
    }
    
    GADRequest *request = [GADRequest request];
    [request registerAdNetworkExtras:extras];
    
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:self.provider.data.key1];

    self.isReward = NO;
}

- (BOOL)isReady {
    return [GADRewardBasedVideoAd sharedInstance].isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];
}

#pragma mark - GADRewardBasedVideoAdDelegate
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    self.isReward = YES;
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    [self.delegate coreAdapter:self
                        coreAd:rewardBasedVideoAd
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate coreAdapter:self didReceivedCoreAd:rewardBasedVideoAd adType:self.adType];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate coreAdapter:self didOpenCoreAd:rewardBasedVideoAd adType:self.adType];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate coreAdapter:self didStartPlayingAd:rewardBasedVideoAd adType:self.adType];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:rewardBasedVideoAd didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self
                didCloseCoreAd:rewardBasedVideoAd
             isCompletePlaying:self.isReward
                        adType:self.adType];
    self.isReward = NO;
}
/// Tells the delegate that the reward based video ad will leave the application.
- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate coreAdapter:self didClickCoreAd:rewardBasedVideoAd adType:self.adType];
}
@end
