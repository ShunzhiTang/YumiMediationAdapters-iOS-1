//
//  YumiMediationVideoAdapterAdColony.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterAdColony.h"
#import <AdColony/AdColony.h>

@interface YumiMediationVideoAdapterAdColony ()

@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) BOOL isReward;
@property (nonatomic) AdColonyInterstitial *video;

@end

@implementation YumiMediationVideoAdapterAdColony

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDAdColony
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    
    __weak typeof(self) weakSelf = self;
    [AdColony configureWithAppID:provider.data.key1
                         zoneIDs:@[ provider.data.key2 ]
                         options:nil
                      completion:^(NSArray<AdColonyZone *> *_Nonnull zones) {
                          [[zones firstObject] setReward:^(BOOL success, NSString *_Nonnull name, int amount) {
                              // NOTE: not reward here but in ad close block
                              weakSelf.isReward = success;
                          }];
                      }];

    return self;
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    [AdColony requestInterstitialInZone:self.provider.data.key2
        options:nil
        success:^(AdColonyInterstitial *_Nonnull ad) {
            weakSelf.isAdReady = YES;
            weakSelf.video = ad;

            [weakSelf.delegate adapter:weakSelf didReceiveVideoAd:weakSelf.video];

            [ad setOpen:^{
                [weakSelf.delegate adapter:weakSelf didOpenVideoAd:weakSelf.video];
                [weakSelf.delegate adapter:weakSelf didStartPlayingVideoAd:weakSelf.video];
            }];
            [ad setClose:^{
                weakSelf.isAdReady = NO;
                if (weakSelf.isReward) {
                    [weakSelf.delegate adapter:weakSelf videoAd:weakSelf.video didReward:nil];
                    weakSelf.isReward = nil;
                }
                [weakSelf.delegate adapter:weakSelf didCloseVideoAd:weakSelf.video];

            }];
        }
        failure:^(AdColonyAdRequestError *_Nonnull error) {
            weakSelf.isAdReady = NO;

            [weakSelf.delegate adapter:weakSelf videoAd:nil didFailToLoad:[error localizedDescription]];
        }];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.video showWithPresentingViewController:rootViewController];
}

- (BOOL)isReady {
    return self.isAdReady;
}

@end
