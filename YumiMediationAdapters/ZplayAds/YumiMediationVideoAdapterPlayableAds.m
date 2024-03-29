//
//  YumiMediationVideoAdapterPlayableAds.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterPlayableAds.h"
#import <YumiMediationSDK/PlayableAds.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiLogger.h>
#import <YumiMediationSDK/PlayableAdsGDPR.h>

@interface YumiMediationVideoAdapterPlayableAds () <PlayableAdsDelegate>

@property (nonatomic) PlayableAds *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterPlayableAds

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDPlayableAds
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;
    
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return  @"2.6.0";
}

- (void)requestAd {
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusPersonalized];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
         [[PlayableAdsGDPR sharedGDPRManager] updatePlayableAdsConsentStatus:PlayableAdsConsentStatusNonPersonalized];
    }
    
    // playableads auto load
    if (!self.video) {
        [[YumiLogger stdLogger] debug:@"---ZplayAds only init and request"];
        self.video = [[PlayableAds alloc] initWithAdUnitID:self.provider.data.key2 appID:self.provider.data.key1];
        self.video.delegate = self;
        self.video.autoLoad = YES;
        [self.video loadAd];
    }
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---ZplayAds start present"];
    [self.video present];
}

#pragma mark - PlayableAdsDelegate

- (void)playableAdsDidRewardUser:(PlayableAds *)ads {
    self.isReward = YES;
}

- (void)playableAdsDidLoad:(PlayableAds *)ads {
    [[YumiLogger stdLogger] debug:@"---ZplayAds did load"];
    [self.delegate coreAdapter:self didReceivedCoreAd:ads adType:self.adType];
}

- (void)playableAds:(PlayableAds *)ads didFailToLoadWithError:(NSError *)error {
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)playableAdsDidStartPlaying:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didOpenCoreAd:ads adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:ads adType:self.adType];
}

- (void)playableAdsDidDismissScreen:(PlayableAds *)ads {
    if (self.isReward) {
        [[YumiLogger stdLogger] debug:@"---ZplayAds did reward"];
        [self.delegate coreAdapter:self coreAd:ads didReward:YES adType:self.adType];
    }
    [[YumiLogger stdLogger] debug:@"---ZplayAds did close"];
    [self.delegate coreAdapter:self didCloseCoreAd:ads isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
}
/// Tells the delegate that the ad is clicked
- (void)playableAdsDidClick:(PlayableAds *)ads {
    [self.delegate coreAdapter:self didClickCoreAd:ads adType:self.adType];
}
@end
