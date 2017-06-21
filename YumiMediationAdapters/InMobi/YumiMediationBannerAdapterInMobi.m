//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterInMobi.h"
#import "YumiMediationAdapterRegistry.h"
#import <InMobiSDK/InMobiSDK.h>

@interface YumiMediationBannerAdapterInMobi () <IMBannerDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) IMBanner *bannerView;

@end

@implementation YumiMediationBannerAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10010"
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    [IMSdk initWithAccountID:provider.data.key1];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    CGRect adFrame = isiPad ? CGRectMake(0, 0, 728, 90) : CGRectMake(0, 0, 320, 50);
    long long placementId = [self.provider.data.key2 longLongValue];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView = [[IMBanner alloc] initWithFrame:adFrame placementId:placementId delegate:strongSelf];

        [strongSelf.bannerView load];
    });
}

#pragma mark - IMBannerDelegate
- (void)bannerDidFinishLoading:(IMBanner *)banner {
    [self.delegate adapter:self didReceiveAd:banner];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate adapter:self didFailToReceiveAd:error.description];
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params {
    [self.delegate adapter:self didClick:banner];
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
}

- (void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
}

@end
