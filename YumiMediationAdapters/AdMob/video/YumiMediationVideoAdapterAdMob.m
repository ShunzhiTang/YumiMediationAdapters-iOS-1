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

@interface YumiMediationVideoAdapterAdMob () <GADRewardedAdDelegate>
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;

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
        return self;
    }

    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        [standardUserDefaults setObject:@"Admob_is_starting" forKey:YumiMediationAdmobAdapterUUID];
        [standardUserDefaults synchronize];
    }];

    return self;
}

- (NSString*)networkVersion {
    return @"7.44.0";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {

    self.isReward = NO;
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

    __weak typeof(self) weakSelf = self;

    self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:self.provider.data.key1];

    [self.rewardedAd
              loadRequest:request
        completionHandler:^(GADRequestError *_Nullable error) {
            if (error) {
                [weakSelf.delegate coreAdapter:weakSelf
                                        coreAd:weakSelf.rewardedAd
                                 didFailToLoad:[error localizedDescription]
                                        adType:weakSelf.adType];
                return;
            }
            //  Ad successfully loaded.
            [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:weakSelf.rewardedAd adType:weakSelf.adType];

        }];
}

- (BOOL)isReady {
    return self.rewardedAd.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.rewardedAd presentFromRootViewController:rootViewController delegate:self];
}

#pragma mark - GADRewardedAdDelegate
/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd userDidEarnReward:(nonnull GADAdReward *)reward {
    self.isReward = YES;
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd didFailToPresentWithError:(nonnull NSError *)error {
    [self.delegate coreAdapter:self
                failedToShowAd:self.rewardedAd
                   errorString:[error localizedDescription]
                        adType:self.adType];
}

/// Tells the delegate that the rewarded ad was presented.
- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd {
    [self.delegate coreAdapter:self didOpenCoreAd:self.rewardedAd adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.rewardedAd adType:self.adType];
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:self.rewardedAd didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:self.rewardedAd isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}

@end
