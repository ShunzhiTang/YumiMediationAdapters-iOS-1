//
//  YumiMediationBannerAdapterInneractive.m
//  Pods
//
//  Created by generator on 22/05/2019.
//
//

#import "YumiMediationBannerAdapterInneractive.h"
#import <IASDKCore/IASDKCore.h>
#import <IASDKMRAID/IASDKMRAID.h>
#import <IASDKVideo/IASDKVideo.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>

@interface YumiMediationBannerAdapterInneractive () <YumiMediationBannerAdapter, IAUnitDelegate, IAVideoContentDelegate,
                                                     IAMRAIDContentDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

// inneractive
@property (nonatomic, strong, nonnull) IAViewUnitController *viewUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong, nonnull) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, weak) IAAdView *adView;

// banner
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterInneractive

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDInneractive
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
        [[IASDKCore sharedInstance] setGDPRConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:NO];
    }

    __weak typeof(self) weakSelf = self;

    // Initialisation of the SDK
    [[IASDKCore sharedInstance] initWithAppID:provider.data.key1];

    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder> _Nonnull builder) {
        builder.useSecureConnections = NO; // To send secure requests only, please set useSecureConnections to YES
        builder.spotID = provider.data.key2;
        builder.timeout = provider.data.requestTimeout;
        builder.keywords = nil;
        builder.autoLocationUpdateEnabled = NO;
    }];
    // 5.Initialize your Video Content Controller:
    self.videoContentController =
        [IAVideoContentController build:^(id<IAVideoContentControllerBuilder> _Nonnull builder) {
            builder.videoContentDelegate = weakSelf;
        }];

    self.MRAIDContentController =
        [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder> _Nonnull builder) {
            builder.MRAIDContentDelegate = weakSelf;
        }];

    // 7. Initialize thefullscreen Controller
    self.viewUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder> _Nonnull builder) {
        builder.unitDelegate = weakSelf;

        [builder addSupportedContentController:weakSelf.videoContentController];
        [builder addSupportedContentController:weakSelf.MRAIDContentController];
    }];
    // 9.Initializing your Ad Spot
    self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> _Nonnull builder) {
        builder.adRequest = adRequest; // pass here the ad request object;
        [builder addSupportedUnitController:weakSelf.viewUnitController];
    }];

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
            didFailToReceiveAd:@"Inneractive not support kYumiMediationAdViewSmartBannerPortrait or "
                               @"kYumiMediationAdViewSmartBannerLandscape"];
        return;
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self didFailToReceiveAd:@"Inneractive not support kYumiMediationAdViewBanner300x250"];
        return;
    }

    __weak typeof(self) weakSelf = self;

    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:NO];
    }

    [self.adSpot
        fetchAdWithCompletion:^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
            if (error) {
                [weakSelf.delegate adapter:self didFailToReceiveAd:error.description];
                return;
            }
            if (adSpot.activeUnitController == weakSelf.viewUnitController) {

                weakSelf.adView = weakSelf.viewUnitController.adView;
                [weakSelf.delegate adapter:weakSelf didReceiveAd:weakSelf.adView];
            }

        }];
}

#pragma mark - IAUnitDelegate

- (UIViewController *_Nonnull)IAParentViewControllerForUnitController:(IAUnitController *_Nullable)unitController {

    return [self.delegate rootViewControllerForPresentingModalView];
}

- (void)IAAdDidReceiveClick:(IAUnitController *_Nullable)unitController {
    [self.delegate adapter:self didClick:self.adView];
}
- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController *_Nullable)unitController {
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController *_Nullable)unitController {
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController *_Nullable)contentController {
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
       videoInterruptedWithError:(NSError *)error {
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
            videoDurationUpdated:(NSTimeInterval)videoDuration {
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
    videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime
                              totalTime:(NSTimeInterval)totalTime {
}

#pragma mark - IAMRAIDContentDelegate

- (void)IAMRAIDContentController:(IAMRAIDContentController *_Nullable)contentController
        MRAIDAdWillResizeToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController *_Nullable)contentController
         MRAIDAdDidResizeToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController *_Nullable)contentController
        MRAIDAdWillExpandToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController *_Nullable)contentController
         MRAIDAdDidExpandToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController *_Nullable)contentController {
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController *_Nullable)contentController {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController *_Nullable)contentController
       videoInterruptedWithError:(NSError *_Nonnull)error {
}

@end
