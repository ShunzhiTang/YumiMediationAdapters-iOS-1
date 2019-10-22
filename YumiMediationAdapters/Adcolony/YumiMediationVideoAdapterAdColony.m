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

@property (nonatomic, assign) BOOL isReward;
@property (nonatomic, assign) BOOL isConfigured;
@property (nonatomic) AdColonyInterstitial *video;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationVideoAdapterAdColony
- (NSString *)networkVersion {
    return @"4.1.1";
}

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
    self.isConfigured = NO;
    self.isReward = NO;
    self.video = nil;

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    // update adcolony gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    AdColonyAppOptions *options = [AdColonyAppOptions new];
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        options.gdprRequired = true;
        options.gdprConsentString = @"1";
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        options.gdprRequired = false;
        options.gdprConsentString = @"0";
    }
    [AdColony setAppOptions:options];
    
    if (self.isConfigured) {
        [AdColony requestInterstitialInZone:self.provider.data.key2 options:nil andDelegate:self];
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [AdColony configureWithAppID:self.provider.data.key1
                         zoneIDs:@[ self.provider.data.key2 ]
                         options:options
                      completion:^(NSArray<AdColonyZone *> *_Nonnull zones) {
                          weakSelf.isConfigured = YES;
                          [AdColony requestInterstitialInZone:weakSelf.provider.data.key2 options:nil andDelegate:weakSelf];
                          [[zones firstObject] setReward:^(BOOL success, NSString *_Nonnull name, int amount) {
                              // NOTE: not reward here but in ad close block
                              weakSelf.isReward = success;
                          }];
                      }];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    BOOL showState = [self.video showWithPresentingViewController:rootViewController];
    if (!showState) {
        [self.delegate coreAdapter:self failedToShowAd:self.video errorString:@"AdColony show fail... " adType:self.adType];
    }
}

- (BOOL)isReady {
    if (self.video) {
        return YES;
    }
    return NO;
}

#pragma mark: AdColonyInterstitialDelegate
/**
 @abstract Did load notification
 @discussion Notifies you when interstitial has been created, received an ad and is ready to use. Call is dispatched on main thread.
 @param interstitial Loaded interstitial
 */
- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    self.video = interstitial;
    [self.delegate coreAdapter:self didReceivedCoreAd:self.video adType:self.adType];
}

/**
 @abstract No ad notification
 @discussion Notifies you when SDK was not able to load an ad for requested zone. Call is dispatched on main thread.
 @param error Error with failure explanation
 */
- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    self.video = nil;
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:[error localizedDescription] adType:self.adType];
}

/**
 @abstract Open notification
 @discussion Notifies you when interstitial is going to show fullscreen content. Call is dispatched on main thread.
 @param interstitial interstitial ad object
 */
- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.delegate coreAdapter:self didOpenCoreAd:self.video adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.video adType:self.adType];
}

/**
 @abstract Close notification
 @discussion Notifies you when interstitial dismissed fullscreen content. Call is dispatched on main thread.
 @param interstitial interstitial ad object
 */
- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    if (self.isReward) {
        [self.delegate coreAdapter:self coreAd:self.video didReward:YES adType:self.adType];
    }
    [self.delegate coreAdapter:self
                    didCloseCoreAd:self.video
                 isCompletePlaying:self.isReward
                            adType:self.adType];
    self.isReward = NO;
    self.video = nil;
}

/**
 @abstract Expire notification
 @discussion Notifies you when an interstitial expires and is no longer valid for playback. This does not get triggered when the expired flag is set because it has been viewed. It's recommended to request a new ad within this callback. Call is dispatched on main thread.
 @param interstitial interstitial ad object
 */
- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    // handle with show status.
}

/**
 @abstract Will leave application notification
 @discussion Notifies you when an ad action cause the user to leave application. Call is dispatched on main thread.
 @param interstitial interstitial ad object
 */
- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
    
}

/**
 @abstract Click notification
 @discussion Notifies you when the user taps on the interstitial causing the action to be taken. Call is dispatched on main thread.
 @param interstitial interstitial ad object
 */
- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
     [self.delegate coreAdapter:self didClickCoreAd:self.video adType:self.adType];
}

/** @name Videos For Purchase (V4P) */

/**
 @abstract IAP opportunity notification
 @discussion Notifies you when the ad triggers an IAP opportunity.
 @param interstitial interstitial ad object
 @param iapProductID IAP product id
 @param engagement engagement type
 */
- (void)adColonyInterstitial:(AdColonyInterstitial * _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(AdColonyIAPEngagement)engagement {
    
}

@end
