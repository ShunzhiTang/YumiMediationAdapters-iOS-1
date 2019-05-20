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
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationVideoAdapterInneractive ()<IAVideoContentDelegate,IAUnitDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAViewUnitController *viewUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;

@property (nonatomic, assign)BOOL isVideoReady;

@end

@implementation YumiMediationVideoAdapterInneractive

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
    
    //Initialisation of the SDK
    [[IASDKCore sharedInstance] initWithAppID:provider.data.key1];
    
    //4. Next comes the ad request object initialization:
    IAAdRequest *adRequest =
    [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.useSecureConnections = NO; //To send secure requests only, please set useSecureConnections to YES
        builder.spotID = provider.data.key2;
        builder.timeout = provider.data.requestTimeout;
        builder.keywords = nil;
        builder.autoLocationUpdateEnabled = NO;
    }];
    // 5.Initialize your Video Content Controller:
    IAVideoContentController *videoContentController =
    [IAVideoContentController build:
     ^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
         builder.videoContentDelegate = self; // a delegate should be passed in order to get video content related callbacks;
     }];
    
    self.videoContentController = videoContentController;
    
    //7. Initialize the View Unit Controller
    IAViewUnitController *viewUnitController =
    [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
        builder.unitDelegate = self;
        // all the needed content controllers should be added to the desired unit controller:
        [builder addSupportedContentController:self.videoContentController];
    }];
    
    self.viewUnitController = viewUnitController; // the View Unit Controller should be retained by a client side;
    
    //9.Initializing your Ad Spot
    IAAdSpot *adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest; // pass here the ad request object;
        // all the supported (by a client side) unit controllers,
        // (in this case - view unit controller) should be added to the desired ad spot:
        [builder addSupportedUnitController:self.viewUnitController];
    }];
    
    self.adSpot = adSpot; // the Ad Spot should be retained by a client side;
    
    return self;
}

- (void)requestAd {
    
    self.isVideoReady = NO;
    // declare a weak property, because of block:
    __weak typeof(self) weakSelf = self;
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        if (error) {
            weakSelf.isVideoReady = NO;
            [weakSelf.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:weakSelf.adType];
        }
    }];
}

- (BOOL)isReady {
    return self.isVideoReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.adSpot.activeUnitController == self.viewUnitController) {
        [self.viewUnitController showAdInParentView:rootViewController.view];
    }
}

#pragma mark: IAVideoContentDelegate
- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController{
    self.isVideoReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:nil adType:self.adType];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error{
    self.isVideoReady = NO;
    [self.delegate coreAdapter:self failedToShowAd:nil errorString:error.localizedDescription adType:self.adType];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration{
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime    totalTime:(NSTimeInterval)totalTime{
}

#pragma mark: IAUnitDelegate
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController{
    
    return [[YumiTool sharedTool] topMostController];;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController{
    [self.delegate coreAdapter:self didClickCoreAd:nil adType:self.adType];
}
- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController{
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitControllerP{
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}
- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController{
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController{
   [self.delegate coreAdapter:self coreAd:nil didReward:YES adType:self.adType];
   [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:YES adType:self.adType];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController{
}

@end
