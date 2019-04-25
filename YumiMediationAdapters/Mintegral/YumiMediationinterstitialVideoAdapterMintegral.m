//
//  YumiMediationinterstitialVideoAdapterMintegral.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2019/2/28.
//

#import "YumiMediationinterstitialVideoAdapterMintegral.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>

@interface YumiMediationinterstitialVideoAdapterMintegral () <MTGInterstitialVideoDelegate>
@property (nonatomic, strong) MTGInterstitialVideoAdManager *ivAdManager;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationinterstitialVideoAdapterMintegral
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDMobvistaInterstitial
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MTGSDK sharedInstance] setAppID:weakSelf.provider.data.key1 ApiKey:weakSelf.provider.data.key2];
        if (!weakSelf.ivAdManager) {
            weakSelf.ivAdManager =
                [[MTGInterstitialVideoAdManager alloc] initWithUnitID:weakSelf.provider.data.key3 delegate:weakSelf];
            weakSelf.ivAdManager.delegate = weakSelf;
        }
    });
    return self;
}

- (void)requestAd {
    [_ivAdManager loadAd];
}

- (BOOL)isReady {
    return self.available;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    self.available = NO;
    [_ivAdManager showFromViewController:rootViewController];
}

#pragma mark - Interstitial Delegate Methods
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    self.available = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}
- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager;
{
    self.available = NO;
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted
                                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    self.available = NO;
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
}

@end
