//
//  YumiMediationVideoAdapterInneractive.m
//  Pods
//
//  Created by generator on 17/05/2019.
//
//

#import "YumiMediationVideoAdapterInneractive.h"
#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationVideoAdapterInneractive () <IAVideoContentDelegate, IAUnitDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *fullscreenUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, assign) BOOL isVideoReady;
@property (nonatomic, assign) BOOL isVideoRewarded;

@end

@implementation YumiMediationVideoAdapterInneractive
- (NSString *)networkVersion {
    return @"7.4.1";
}

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInneractive
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeVideo];
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

    // 4. Next comes the ad request object initialization:
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

    // 7. Initialize the View Unit Controller
    self.fullscreenUnitController =
        [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder) {
            builder.unitDelegate = weakSelf;
            [builder addSupportedContentController:weakSelf.videoContentController];
        }];

    // 9.Initializing your Ad Spot
    self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> _Nonnull builder) {
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:weakSelf.fullscreenUnitController];
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did init adSpot"];
    }];
    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    self.isVideoReady = NO;
    self.isVideoRewarded = NO;

    // update gdpr
    YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

    if (gdprStatus == YumiMediationConsentStatusPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:YES];
    }
    if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
        [[IASDKCore sharedInstance] setGDPRConsent:NO];
    }

    // declare a weak prop-erty, because of block:
    __weak typeof(self) weakSelf = self;
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK start request"];
    [self.adSpot
        fetchAdWithCompletion:^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
            if (error) {
                weakSelf.isVideoReady = NO;
                [weakSelf.delegate coreAdapter:weakSelf
                                        coreAd:nil
                                 didFailToLoad:error.localizedDescription
                                        adType:weakSelf.adType];
                [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did fail to load"];
                return;
            }
            weakSelf.isVideoReady = YES;
            [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:nil adType:weakSelf.adType];
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did load"];
        }];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---InneractiveAdSDK check ready status.%d",self.isVideoReady];
    [[YumiLogger stdLogger] debug:msg];
    return self.isVideoReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.adSpot.activeUnitController == self.fullscreenUnitController) {
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK present"];
        [self.fullscreenUnitController showAdAnimated:YES completion:nil];
    }
}

#pragma mark : IAVideoContentDelegate
- (void)IAVideoCompleted:(IAVideoContentController *_Nullable)contentController {
    self.isVideoRewarded = YES;
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
       videoInterruptedWithError:(NSError *_Nonnull)error {
    self.isVideoReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
            videoDurationUpdated:(NSTimeInterval)videoDuration {
}

- (void)IAVideoContentController:(IAVideoContentController *_Nullable)contentController
    videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime
                              totalTime:(NSTimeInterval)totalTime {
}

#pragma mark : IAUnitDelegate
- (UIViewController *_Nonnull)IAParentViewControllerForUnitController:(IAUnitController *_Nullable)unitController {
    return [[YumiTool sharedTool] topMostController];
}

- (void)IAAdDidReceiveClick:(IAUnitController *_Nullable)unitController {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
- (void)IAAdWillLogImpression:(IAUnitController *_Nullable)unitController {
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController *_Nullable)unitControllerP {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController *_Nullable)unitController {
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController *_Nullable)unitController {
    if (self.isVideoRewarded) {
        [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK did rewarded"];
        [self.delegate coreAdapter:self coreAd:nil didReward:self.isVideoRewarded adType:self.adType];
    }
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:self.isVideoRewarded adType:self.adType];
    self.isVideoRewarded = NO;
    self.isVideoReady = NO;
    [[YumiLogger stdLogger] debug:@"---InneractiveAdSDK closed"];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController *_Nullable)unitController {
}

@end
