//
//  YumiMediationVideoAdapterDomob.m
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import "YumiMediationVideoAdapterDomob.h"
#import "DMAdVideoManager.h"
#import <YumiMediationSDK/YumiLogger.h>
#import <YumiMediationSDK/YumiMediationConstants.h>
#import <YumiMediationSDK/YumiLogger.h>

@interface YumiMediationVideoAdapterDomob () <DMAdVideoManagerDelegate>

@property (nonatomic) DMAdVideoManager *videoManager;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL isReward;

@end

@implementation YumiMediationVideoAdapterDomob
- (NSString *)networkVersion {
    return @"3.8.0";
}

+ (void)load {
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [[YumiLogger stdLogger] info:@"Domob don't support iOS version below 9.0"];
        return;
    }
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDDomob
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

    self.videoManager = [[DMAdVideoManager alloc] initWithPublisherID:self.provider.data.key1];
    self.videoManager.delegate = self;

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {
    [[YumiLogger stdLogger] debug:@"---Domob start request"];
    [self.videoManager loadAd];
}

- (BOOL)isReady {
    NSString *msg = [NSString stringWithFormat:@"---Domob check ready status.%d",self.available];
    [[YumiLogger stdLogger] debug:msg];
    return self.available;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [[YumiLogger stdLogger] debug:@"---Domob present"];
    [self.videoManager presentADVideoControllerWithViewController:rootViewController];
    [self.delegate coreAdapter:self didOpenCoreAd:nil adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:nil adType:self.adType];
}

#pragma mark - IndependentVideoManagerDelegate
- (void)AdVideoManagerDidFinishLoad:(DMAdVideoManager *_Nonnull)manager {
    self.available = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:manager adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---Domob did load"];
}

- (void)AdVideoManager:(DMAdVideoManager *_Nonnull)manager failedLoadWithError:(NSError *__nullable)error {
    self.available = NO;
    [self.delegate coreAdapter:self coreAd:manager didFailToLoad:[error localizedDescription] adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---Domob did fail to load"];
}

- (void)AdVideoManagerPlayVideoComplete:(DMAdVideoManager *_Nonnull)manager {
    self.available = NO;
    self.isReward = YES;
    [self.delegate coreAdapter:self coreAd:manager didReward:YES adType:self.adType];
    [[YumiLogger stdLogger] debug:@"---Domob did rewarded"];
}

- (void)AdVideoManagerCloseVideoPlayer:(DMAdVideoManager *_Nonnull)manager {
    [self.delegate coreAdapter:self didCloseCoreAd:manager isCompletePlaying:self.isReward adType:self.adType];
    self.isReward = NO;
    self.available = NO;
    [[YumiLogger stdLogger] debug:@"---Domob did closed"];
}

@end
