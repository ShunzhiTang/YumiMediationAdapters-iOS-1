//
//  YumiMediationInterstitialAdapterInneractive.m
//  Pods
//
//  Created by generator on 22/05/2019.
//
//

#import "YumiMediationInterstitialAdapterInneractive.h"
#import <IASDKCore/IASDKCore.h>
#import <IASDKMRAID/IASDKMRAID.h>
#import <IASDKVideo/IASDKVideo.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationInterstitialAdapterInneractive () <IAUnitDelegate, IAVideoContentDelegate,
                                                           IAMRAIDContentDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL isInterstitalReady;
// inneractive
@property (nonatomic, strong) IAFullscreenUnitController *fullscreenUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong, nonnull) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) IAAdSpot *adSpot;

@end

@implementation YumiMediationInterstitialAdapterInneractive
- (NSString *)networkVersion {
    return @"7.4.1";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInneractive
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark - YumiMediationVideoAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;
    self.adType = adType;

    __weak typeof(self) weakSelf = self;
    // set gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:NO];
    }
    
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init"];
    // Initialisation of the SDK
    [[IASDKCore sharedInstance] initWithAppID:provider.data.key1];
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init adRequest"];
    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder> _Nonnull builder) {
        builder.useSecureConnections = NO; // To send secure requests only, please set useSecureConnections to YES
        builder.spotID = provider.data.key2;
        builder.timeout = provider.data.requestTimeout;
        builder.keywords = nil;
        builder.autoLocationUpdateEnabled = NO;
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init adRequest"];
    }];
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init videoContentController"];
    // 5.Initialize your Video Content Controller:
    self.videoContentController =
        [IAVideoContentController build:^(id<IAVideoContentControllerBuilder> _Nonnull builder) {
            builder.videoContentDelegate = weakSelf;
            [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init videoContentController"];
        }];
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init mraid"];
    self.MRAIDContentController =
        [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder> _Nonnull builder) {
            builder.MRAIDContentDelegate = weakSelf;
            [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init mraid"];
        }];
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init fullscreenUnitController"];
    // 7. Initialize thefullscreen Controller
    self.fullscreenUnitController =
        [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder) {
            builder.unitDelegate = weakSelf;
            [builder addSupportedContentController:weakSelf.videoContentController];
            [builder addSupportedContentController:weakSelf.MRAIDContentController];
            [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init fullscreenUnitController"];
        }];
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start init adSpot"];
    // 9.Initializing your Ad Spot
    self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> _Nonnull builder) {
        builder.adRequest = adRequest; // pass here the ad request object;
        [builder addSupportedUnitController:weakSelf.fullscreenUnitController];
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init adSpot"];
    }];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    self.isInterstitalReady = NO;
    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:NO];
    }
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start request"];
    [self.adSpot
        fetchAdWithCompletion:^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
            if (error) {
                weakSelf.isInterstitalReady = NO;
                [weakSelf.delegate coreAdapter:weakSelf
                                        coreAd:nil
                                 didFailToLoad:error.localizedDescription
                                        adType:weakSelf.adType];
                [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did fail to load"];
                return;
            }
            weakSelf.isInterstitalReady = YES;
            [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:nil adType:weakSelf.adType];
            [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did load"];
        }];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---InneractiveAdSDK check ready status.%d",self.isInterstitalReady];
    [[YumiLogger stdLogger] debug:msg];
    return self.isInterstitalReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.adSpot.activeUnitController == self.fullscreenUnitController) {
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK present"];
        [self.fullscreenUnitController showAdAnimated:YES completion:nil];
    }
}
#pragma mark - IAUnitDelegate
- (UIViewController *_Nonnull)IAParentViewControllerForUnitController:(IAUnitController *_Nullable)unitController {
    return [[YumiTool sharedTool] topMostController];
}

- (void)IAAdDidReceiveClick:(IAUnitController *_Nullable)unitController {
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK click"];
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController *_Nullable)unitController {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController *_Nullable)unitController {
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK closed"];
    self.isInterstitalReady = NO;
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController *_Nullable)contentController {
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
       videoInterruptedWithError:(NSError *)error {
    self.isInterstitalReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
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
    self.isInterstitalReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

@end
