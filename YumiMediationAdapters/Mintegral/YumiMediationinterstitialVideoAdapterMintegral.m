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

@end

@implementation YumiMediationinterstitialVideoAdapterMintegral
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDMobvista
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

- (void)present {
    self.available = NO;
    [_ivAdManager showFromViewController:[self.delegate rootViewControllerForPresentingModalView]];
}

#pragma mark - Interstitial Delegate Methods
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    self.available = YES;
    [self.delegate adapter:self didReceiveInterstitialAd:nil];
}
- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager;
{
    self.available = NO;
    [self.delegate adapter:self interstitialAd:nil didFailToReceive:error.localizedDescription];
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate adapter:self willPresentScreen:nil];
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error
                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self.delegate adapter:self didClickInterstitialAd:nil];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted
                                          adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    self.available = NO;
    [self.delegate adapter:self willDismissScreen:nil];
}

@end
