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

@interface YumiMediationVideoAdapterAdColony ()

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
    return @"3.3.7";
}

- (void)requestAd {
    self.isAdReady = NO;
    self.isReward = NO;

    __weak typeof(self) weakSelf = self;
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

    [AdColony requestInterstitialInZone:self.provider.data.key2
        options:nil
        success:^(AdColonyInterstitial *_Nonnull ad) {
            weakSelf.isAdReady = YES;
            weakSelf.video = ad;
            [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:weakSelf.video adType:weakSelf.adType];
            [ad setOpen:^{
                [weakSelf.delegate coreAdapter:weakSelf didOpenCoreAd:weakSelf.video adType:weakSelf.adType];
                [weakSelf.delegate coreAdapter:weakSelf didStartPlayingAd:weakSelf.video adType:weakSelf.adType];
            }];
            [ad setClose:^{
                if (weakSelf.isReward) {
                    [weakSelf.delegate coreAdapter:weakSelf coreAd:weakSelf.video didReward:YES adType:weakSelf.adType];
                }
                [weakSelf.delegate coreAdapter:weakSelf
                                didCloseCoreAd:weakSelf.video
                             isCompletePlaying:weakSelf.isReward
                                        adType:weakSelf.adType];
                weakSelf.isAdReady = NO;
                weakSelf.isReward = NO;
            }];
            [ad setClick:^{
                [weakSelf.delegate coreAdapter:weakSelf didClickCoreAd:weakSelf.video adType:weakSelf.adType];
            }];
        }
        failure:^(AdColonyAdRequestError *_Nonnull error) {
            weakSelf.isAdReady = NO;
            [weakSelf.delegate coreAdapter:weakSelf
                                    coreAd:nil
                             didFailToLoad:[error localizedDescription]
                                    adType:weakSelf.adType];
        }];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showWithPresentingViewController:rootViewController];
}

- (BOOL)isReady {
    return self.isAdReady;
}

@end
