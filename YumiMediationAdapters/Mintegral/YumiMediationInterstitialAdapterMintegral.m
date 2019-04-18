//
//  YumiMediationInterstitialAdapterMintegral.m
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2019/2/28.
//

#import "YumiMediationInterstitialAdapterMintegral.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitial/MTGInterstitialAdManager.h>

@interface YumiMediationInterstitialAdapterMintegral () <MTGInterstitialAdLoadDelegate, MTGInterstitialAdShowDelegate>
@property (nonatomic, strong) MTGInterstitialAdManager *interstitialAdManager;
@property (nonatomic, assign) BOOL available;

@end

@implementation YumiMediationInterstitialAdapterMintegral
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDMobvistaInterstitial
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MTGSDK sharedInstance] setAppID:weakSelf.provider.data.key1 ApiKey:weakSelf.provider.data.key2];
        if (!weakSelf.interstitialAdManager) {
            weakSelf.interstitialAdManager =
                [[MTGInterstitialAdManager alloc] initWithUnitID:weakSelf.provider.data.key3 adCategory:0];
        }
    });
    return self;
}

- (void)requestAd {
    [_interstitialAdManager loadWithDelegate:self];
}

- (BOOL)isReady {
    return self.available;
}

- (void)present {
    self.available = NO;
    [_interstitialAdManager showWithDelegate:self
                    presentingViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - Interstitial Delegate Methods
- (void)onInterstitialLoadSuccess:adManager {
    self.available = YES;
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}
- (void)onInterstitialLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialAdManager *_Nonnull)adManager {
    self.available = NO;
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:error.localizedDescription];
}
- (void)onInterstitialShowSuccess:adManager {
    [self.delegate adapter:self willPresentScreen:nil];
}
- (void)onInterstitialShowFail:(nonnull NSError *)error adManager:(MTGInterstitialAdManager *_Nonnull)adManager {
}
- (void)onInterstitialClosed:adManager {
    self.available = NO;
    [self.delegate adapter:self willDismissScreen:nil];
}
- (void)onInterstitialAdClick:adManager {
    [self.delegate adapter:self didClickInterstitialAd:nil];
}

@end
