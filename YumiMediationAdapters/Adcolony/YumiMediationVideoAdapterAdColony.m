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

@property (nonatomic,assign) BOOL isAdReady;
@property (nonatomic,assign) BOOL isReward;
@property (nonatomic) AdColonyInterstitial *video;

@end

@implementation YumiMediationVideoAdapterAdColony

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:[self sharedInstance]
                                                      forProvider:kYumiMediationAdapterIDAdColony
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - YumiMediationVideoAdapter
- (void)setupWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self.delegate = delegate;
    self.provider = provider;

    [AdColony configureWithAppID:provider.data.key1
                         zoneIDs:@[ provider.data.key2 ]
                         options:nil
                      completion:^(NSArray<AdColonyZone *> *_Nonnull zones) {
                          [[zones firstObject] setReward:^(BOOL success, NSString *_Nonnull name, int amount){
                              // NOTE: not reward here but in ad close block
                              self.isReward = success;
                          }];
                      }];
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
                if (self.isReward) {
                    [weakSelf.delegate adapter:weakSelf videoAd:weakSelf.video didReward:nil];
                    self.isReward = NO;
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
