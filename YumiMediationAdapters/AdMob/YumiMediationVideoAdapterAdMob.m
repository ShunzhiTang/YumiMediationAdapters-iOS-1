//
//  YumiMediationVideoAdapterAdMob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdMob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString *YumiMediationAdmobAdapterUUID = @"YumiMediation_AdmobAdapter_UUID";

@interface YumiMediationVideoAdapterAdMob () <GADRewardBasedVideoAdDelegate>
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterAdMob

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDAdMob
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    
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

- (void)requestAd {
    
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:self.provider.data.key1];
    
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
    [self.delegate adapter:self videoAd:rewardBasedVideoAd didFailToLoad:[error localizedDescription]];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didReceiveVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didOpenVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self.delegate adapter:self didStartPlayingVideoAd:rewardBasedVideoAd];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    if (self.isReward) {
        [self.delegate adapter:self videoAd:rewardBasedVideoAd didReward:nil];
        self.isReward = NO;
    }
    [self.delegate adapter:self didCloseVideoAd:rewardBasedVideoAd];
}

@end
