//
//  YumiMediationBannerAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationBannerAdapterIQzone.h"
#import <IMDAdView.h>
#import <IMDSDK.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterIQzone () <YumiMediationBannerAdapter, IMDAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

// IQzone banner
@property (nonatomic) IMDAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDIQzone
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if (self.bannerSize == kYumiMediationAdViewSmartBannerPortrait ||
        self.bannerSize == kYumiMediationAdViewSmartBannerLandscape) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"IQzone not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }

    CGSize adSize = isiPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        adSize = CGSizeMake(300, 250);
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.bannerView =
            [IMDSDK newBannerAd:weakSelf.provider.data.key1 withSize:adSize andDelegate:weakSelf andMetadata:nil];
        [weakSelf.bannerView setGDPRApplies:IMDGDPR_DoesNotApply withConsent:IMDGDPR_NotConsented];
        // set GDPR
        YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

        if (gdprStatus == YumiMediationConsentStatusPersonalized) {
            [weakSelf.bannerView setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_Consented];
        }
        if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
            [weakSelf.bannerView setGDPRApplies:IMDGDPR_Applies withConsent:IMDGDPR_NotConsented];
        }

        [weakSelf.bannerView loadAd];
    });
}

#pragma mark : -IMDAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate rootViewControllerForPresentingModalView];
}

#pragma mark : -IMDAdEventsListener
- (void)adLoaded {
    [self.delegate adapter:self didReceiveAd:self.bannerView];
}
- (void)adFailedToLoad {
    [self.delegate adapter:self didFailToReceiveAd:@"banner load failed"];
}
- (void)adClicked {
    [self.delegate adapter:self didClick:self.bannerView];
}

- (void)adDismissed {
}

- (void)adExpanded {
}

- (void)adImpression {
}

- (void)videoCompleted {
}

- (void)videoSkipped {
}

- (void)videoStarted {
}

- (void)videoTrackerFired {
}

@end
