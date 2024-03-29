//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterInMobi () <IMBannerDelegate, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) IMBanner *bannerView;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDInMobi
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    NSDictionary *consentDict = nil;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(YES) };
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(NO) };
    }

    [IMSdk initWithAccountID:provider.data.key1 consentDictionary:consentDict];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

#pragma mark - YumiMediationBannerAdapter
- (NSString *)networkVersion {
    return @"7.4.0";
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(YES) }];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(NO) }];
    }

    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"inmobi not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }
    
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
           [self.delegate adapter:self
           didFailToReceiveAd:@"inmobi not support kYumiMediationAdViewBanner300x250 "];
        return;
       }
    CGRect adFrame = isiPad ? CGRectMake(0, 0, 728, 90) : CGRectMake(0, 0, 320, 50);
   
    long long placementId = [self.provider.data.key2 longLongValue];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView = [[IMBanner alloc] initWithFrame:adFrame placementId:placementId delegate:strongSelf];
        // set refresh state
        if (strongSelf.provider.data.autoRefreshInterval == 0) {
            [strongSelf.bannerView shouldAutoRefresh:NO];
        } else {
            [strongSelf.bannerView shouldAutoRefresh:YES];
            [strongSelf.bannerView setRefreshInterval:strongSelf.provider.data.autoRefreshInterval];
        }

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
