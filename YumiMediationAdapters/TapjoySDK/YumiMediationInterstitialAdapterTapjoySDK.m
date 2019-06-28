//
//  YumiMediationInterstitialAdapterTapjoySDK.m
//  Pods
//
//  Created by generator on 28/06/2019.
//
//

#import "YumiMediationInterstitialAdapterTapjoySDK.h"
#import <Tapjoy/Tapjoy.h>

@interface YumiMediationInterstitialAdapterTapjoySDK ()<TJPlacementDelegate>

@property (nonatomic, assign) YumiMediationAdType adType;
@property (strong, nonatomic) TJPlacement *interstitialPlacement;

@end

@implementation YumiMediationInterstitialAdapterTapjoySDK

- (void)dealloc {
    self.interstitialPlacement.delegate = nil;
    //    self.interstitialPlacement.videoDelegate = nil;
}
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDTapjoy
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

    // Tapjoy Connect Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
    
    [Tapjoy connect:self.provider.data.key1 options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES)}];
    
    return self;
}

- (void)requestAd {
    
    self.interstitialPlacement = [TJPlacement placementWithName:self.provider.data.key2 delegate:self];
    // Set video delegate TJPlacementVideoDelegate
    //    self.interstitialPlacement.videoDelegate = self;
    [self.interstitialPlacement requestContent];
}

- (BOOL)isReady {
    return self.interstitialPlacement.isContentAvailable;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitialPlacement showContentWithViewController:rootViewController];
}

#pragma mark: privare method
-(void)tjcConnectSuccess:(NSNotification*)notifyObj
{
    // Remove observer after it's notified once
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: TJC_CONNECT_SUCCESS
                                                  object:nil];
}

- (void)tjcConnectFail:(NSNotification*)notifyObj
{
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:@"Tapjoy connect fail" adType:self.adType];
}

#pragma mark: TJPlacementDelegate
- (void)requestDidSucceed:(TJPlacement*)placement {
    
}

- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error {
    [self.delegate coreAdapter:self coreAd:nil didFailToLoad:error.localizedDescription adType:self.adType];
}

- (void)contentIsReady:(TJPlacement*)placement {
    [self.delegate coreAdapter:self didReceivedCoreAd:self.interstitialPlacement adType:self.adType];
}

- (void)contentDidAppear:(TJPlacement*)placement {
    [self.delegate coreAdapter:self didOpenCoreAd:self.interstitialPlacement adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.interstitialPlacement adType:self.adType];
}

- (void)contentDidDisappear:(TJPlacement*)placement {
   
    [self.delegate coreAdapter:self
                didCloseCoreAd:self.interstitialPlacement
             isCompletePlaying:NO
                        adType:self.adType];
    
}
- (void)didClick:(TJPlacement*)placement {
    [self.delegate coreAdapter:self didClickCoreAd:self.interstitialPlacement adType:self.adType];
}
#pragma mark: TJPlacementVideoDelegate
- (void)videoDidStart:(TJPlacement*)placement {
}

- (void)videoDidComplete:(TJPlacement*)placement {
    
}

- (void)videoDidFail:(TJPlacement*)placement error:(NSString*)errorMsg {
    [self.delegate coreAdapter:self failedToShowAd:self.interstitialPlacement errorString:errorMsg adType:self.adType];
}

@end
