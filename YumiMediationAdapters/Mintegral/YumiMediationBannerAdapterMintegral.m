//
//  YumiMediationBannerAdapterMintegral.m
//  Pods
//
//  Created by generator on 18/11/2019.
//
//

#import "YumiMediationBannerAdapterMintegral.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterMintegral () <YumiMediationBannerAdapter,MTGBannerAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;
@property (nonatomic, strong) MTGBannerAdView *bannerAdView;

@end

@implementation YumiMediationBannerAdapterMintegral

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDMobvista
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[MTGSDK sharedInstance] setConsentStatus:NO];
    }

    __weak typeof(self) weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
       [[MTGSDK sharedInstance] setAppID:weakSelf.provider.data.key1 ApiKey:weakSelf.provider.data.key2];
       [[YumiLogger stdLogger] debug:@"---Mintegral banner Set the AppID and ApiKey. "];
   });

    return self;
}

- (NSString *)networkVersion {
    return @"5.7.1";
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
       [[MTGSDK sharedInstance] setConsentStatus:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
       [[MTGSDK sharedInstance] setConsentStatus:NO];
    }
    
    MTGBannerSizeType bannerSize = isiPad ? MTGSmartBannerType : MTGStandardBannerType320x50;
    // smart size
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        bannerSize = MTGSmartBannerType;
    }
    // 300 * 250
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
       bannerSize = MTGMediumRectangularBanner300x250;
    }
    
    self.bannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:bannerSize unitId:self.provider.data.key3 rootViewController:[self.delegate rootViewControllerForPresentingModalView]];

    self.bannerAdView.autoRefreshTime = self.provider.data.autoRefreshInterval;
    self.bannerAdView.delegate = self;

    [self.bannerAdView loadBannerAd];
    
}

#pragma mark: MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    [self.delegate adapter:self didReceiveAd:self.bannerAdView];
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    [self.delegate adapter:self didClick:self.bannerAdView];
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
    //
}


- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    //
}


- (void)adViewWillLogImpression:(MTGBannerAdView *)adView {
    //
}


- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    //
}

@end
