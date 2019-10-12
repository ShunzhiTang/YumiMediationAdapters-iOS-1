//
//  YumiMediationVideoAdapterAdColony.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdColony.h"
#import <AdColony/AdColony.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationVideoAdapterAdColony ()<AdColonyInterstitialDelegate>

@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic) AdColonyInterstitial *video;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterAdColony

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDAdColony
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    AdColonyAppOptions *options = [AdColonyAppOptions new];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        options.gdprRequired = TRUE;
        options.gdprConsentString = @"1";
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        options.gdprRequired = false;
        options.gdprConsentString = @"0";
    }

    __weak typeof(self) weakSelf = self;
    [AdColony configureWithAppID:provider.data.key1
                         zoneIDs:@[ provider.data.key2 ]
                         options:options
                      completion:^(NSArray<AdColonyZone *> *_Nonnull zones) {
                          [[zones firstObject] setReward:^(BOOL success, NSString *_Nonnull name, int amount) {
                              // NOTE: not reward here but in ad close block
                              weakSelf.isReward = success;
                          }];
                      }];

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"4.1.1";
}

- (void)requestAd {
    self.isAdReady = NO;
    self.isReward = NO;
    self.video = nil;
    // update adcolony gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    AdColonyAppOptions *options = [AdColonyAppOptions new];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        options.gdprRequired = TRUE;
        options.gdprConsentString = @"1";
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        options.gdprRequired = false;
        options.gdprConsentString = @"0";
    }

    [AdColony setAppOptions:options];

    [AdColony requestInterstitialInZone:self.provider.data.key2 options:nil andDelegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    
    BOOL showState = [self.video showWithPresentingViewController:rootViewController];
    
    if (!showState) {
        [self.delegate coreAdapter:self failedToShowAd:self.video errorString:@"AdColony show fail... " adType:self.adType];
    }
}

- (BOOL)isReady {
    return self.isAdReady;
}

#pragma mark: AdColonyInterstitialDelegate
- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    self.isAdReady = YES;
    self.video = interstitial;
    [self.delegate coreAdapter:self didReceivedCoreAd:self.video adType:self.adType];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    self.isAdReady = NO;
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:[error localizedDescription] adType:self.adType];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:self.video adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.video adType:self.adType];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:self.video didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self
                    didCloseCoreAd:self.video
                 isCompletePlaying:self.isReward
                            adType:self.adType];
    self.isAdReady = NO;
    self.isReward = NO;
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
     [self.delegate coreAdapter:self didClickCoreAd:self.video adType:self.adType];
}

@end
