//
//  YumiMediationInterstitialAdapterInneractive.m
//  Pods
//
//  Created by generator on 22/05/2019.
//
//

#import "YumiMediationInterstitialAdapterInneractive.h"
#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKMRAID/IASDKMRAID.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterInneractive ()<IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign)BOOL isInterstitalReady;
// inneractive
@property (nonatomic, strong) IAFullscreenUnitController *fullscreenUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong, nonnull) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) IAAdSpot *adSpot;

@end

@implementation YumiMediationInterstitialAdapterInneractive

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
    
    //Initialisation of the SDK
    [[IASDKCore sharedInstance] initWithAppID:provider.data.key1];
    
    IAAdRequest *adRequest =
    [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.useSecureConnections = NO; //To send secure requests only, please set useSecureConnections to YES
        builder.spotID = provider.data.key2;
        builder.timeout = provider.data.requestTimeout;
        builder.keywords = nil;
        builder.autoLocationUpdateEnabled = NO;
    }];
    // 5.Initialize your Video Content Controller:
    self.videoContentController =
    [IAVideoContentController build:
     ^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
         builder.videoContentDelegate = weakSelf;
     }];
    
    _MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
        builder.MRAIDContentDelegate = weakSelf;
    }];
    
    //7. Initialize thefullscreen Controller
    self.fullscreenUnitController =
    [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder)
     {
         builder.unitDelegate = weakSelf;
         [builder addSupportedContentController:weakSelf.videoContentController];
         [builder addSupportedContentController:weakSelf.MRAIDContentController];
     }];
    
    //9.Initializing your Ad Spot
     self.adSpot= [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest; // pass here the ad request object;
        [builder addSupportedUnitController:weakSelf.fullscreenUnitController];
    }];
    
    return self;
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    self.isInterstitalReady = NO;
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        if (error) {
            weakSelf.isInterstitalReady = NO;
            [weakSelf.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:weakSelf.adType];
            return ;
        }
        weakSelf.isInterstitalReady = YES;
        [weakSelf.delegate coreAdapter:weakSelf didReceivedCoreAd:nil adType:weakSelf.adType];
    }];
}

- (BOOL)isReady {
    return self.isInterstitalReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.adSpot.activeUnitController == self.fullscreenUnitController) {
        [self.fullscreenUnitController showAdAnimated:YES completion:nil];
    }
}
#pragma mark - IAUnitDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    
    return [[YumiTool sharedTool] topMostController];
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError *)error {
    self.isInterstitalReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
}

#pragma mark - IAMRAIDContentDelegate

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillResizeToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidResizeToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillExpandToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidExpandToFrame:(CGRect)frame {
}

- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController * _Nullable)contentController {
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController * _Nullable)contentController {
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    self.isInterstitalReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

@end
