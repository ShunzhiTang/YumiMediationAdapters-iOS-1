//
//  YumiMediationBannerAdapterChartboost.m
//  Pods
//
//  Created by generator on 12/08/2019.
//
//

#import "YumiMediationBannerAdapterChartboost.h"
#import <Chartboost/CHBBanner.h>
#import <Chartboost/Chartboost.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterChartboost () <YumiMediationBannerAdapter, ChartboostDelegate, CHBBannerDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@property (nonatomic, strong) CHBBanner *banner;

@end

@implementation YumiMediationBannerAdapterChartboost

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDChartboost
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    // set GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }

    [Chartboost startWithAppId:self.provider.data.key1 appSignature:self.provider.data.key2 delegate:self];

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    
    // update GDPR
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [Chartboost setPIDataUseConsent:YesBehavioral];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [Chartboost setPIDataUseConsent:NoBehavioral];
    }
    
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"Chartboost not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.bannerSize == kYumiMediationAdViewBanner300x250) {
            /// CHBBannerSizeMedium = 300 x 250
            weakSelf.banner =
                [[CHBBanner alloc] initWithSize:CHBBannerSizeMedium location:CBLocationDefault delegate:weakSelf];
        } else {
            if (isiPad) {
                /// CHBBannerSizeLeaderboard = 728 x 90
                weakSelf.banner = [[CHBBanner alloc] initWithSize:CHBBannerSizeLeaderboard
                                                         location:CBLocationDefault
                                                         delegate:weakSelf];
            }
            // iphone
            if (!isiPad) {
                /// CHBBannerSizeStandard = 320 x 50
                weakSelf.banner = [[CHBBanner alloc] initWithSize:CHBBannerSizeStandard
                                                         location:CBLocationHomeScreen
                                                         delegate:weakSelf];
            }
        }
        // Manually handling banner refresh
        if (weakSelf.provider.data.autoRefreshInterval == 0) {
            weakSelf.banner.automaticallyRefreshesContent = NO;
            [weakSelf.banner cache];
        } else {
            // Auto-refreshing
            weakSelf.banner.automaticallyRefreshesContent = YES;
            [weakSelf.banner showFromViewController:[weakSelf.delegate rootViewControllerForPresentingModalView]];
        }

    });
}

#pragma mark - ChartboostDelegate
///  status The result of the initialization. YES if successful. NO if failed.
- (void)didInitialize:(BOOL)status {
    if (!status) {
        [self.delegate adapter:self didFailToReceiveAd:@"Chartboost initialize fail.."];
    }
}

#pragma mark : CHBBannerDelegate
- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error {
    if (error || !self.banner.isCached) {
        [self.delegate adapter:self
            didFailToReceiveAd:[NSString stringWithFormat:@"Chartboost load fail. error code is %ld", error.code]];
        return;
    }
    // Show banner after it has been cached if Manually handling refresh
    if (!self.banner.automaticallyRefreshesContent) {
        [self.banner showFromViewController:[self.delegate rootViewControllerForPresentingModalView]];
    }

    [self.delegate adapter:self didReceiveAd:self.banner];
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    if (error) {
        [self.delegate adapter:self
            didFailToReceiveAd:[NSString stringWithFormat:@"Chartboost show fail. error code is %ld", error.code]];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    [self.delegate adapter:self didClick:self.banner];
}

@end
