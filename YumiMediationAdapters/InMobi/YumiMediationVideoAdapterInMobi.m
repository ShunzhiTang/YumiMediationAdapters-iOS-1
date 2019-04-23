//
//  YumiMediationVideoAdapterInMobi.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>

@interface YumiMediationVideoAdapterInMobi () <IMInterstitialDelegate>

@property (nonatomic) IMInterstitial *video;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) YumiMediationAdType adType;
@end

@implementation YumiMediationVideoAdapterInMobi

+ (void)load {
     [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self forProviderID:kYumiMediationAdapterIDInMobi requestType:YumiMediationSDKAdRequest adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType  {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;
    
    [IMSdk initWithAccountID:self.provider.data.key1];
    self.video = [[IMInterstitial alloc] initWithPlacementId:[self.provider.data.key2 longLongValue] delegate:self];

    return self;
}

- (void)requestAd {
    [self.video load];
}

- (BOOL)isReady {
    return self.video.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showFromViewController:rootViewController];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
     [self.delegate coreAdapter:self failedToShowAd:interstitial errorString:error.localizedDescription adType:self.adType];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {

    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:interstitial didReward:YES adType:self.adType];
        self.isReward = NO;
    }
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:YES adType:self.adType];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    self.isReward = YES;
}
///  Notifies the delegate that the user will leave application context.
-(void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
     [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

@end
