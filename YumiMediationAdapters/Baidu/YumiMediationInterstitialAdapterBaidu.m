//
//  YumiMediationInterstitialAdapterBaidu.m
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import "YumiMediationInterstitialAdapterBaidu.h"
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>
#import <YumiMediationSDK/YumiTool.h>
#import <YumiMediationSDK/YumiMasonry.h>

@interface YumiMediationInterstitialAdapterBaidu () <BaiduMobAdInterstitialDelegate>

@property (nonatomic) BaiduMobAdInterstitial *interstitial;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic, assign) BOOL interstitialIsReady;

@property (nonatomic) UIView *customInterView;
@property (nonatomic, assign) CGSize adSize;

@end

@implementation YumiMediationInterstitialAdapterBaidu

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDBaidu
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

- (void)dealloc {
    [self clearInterstitial];
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;
    self.interstitialIsReady = NO;
    
    return self;
}

- (void)requestAd {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.interstitial = [[BaiduMobAdInterstitial alloc] init];
        weakSelf.interstitial.delegate = weakSelf;
        weakSelf.interstitial.AdUnitTag = weakSelf.provider.data.key2;
        
        //aspectRatio = width : height
        float aspectRatio = [self.provider.data.extra[YumiProviderExtraBaidu] floatValue];
        
        if (aspectRatio == 0) {
            weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
            [weakSelf.interstitial load];
            return ;
        }
       
        weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;
        
        float width = MIN(kSCREEN_WIDTH, kSCREEN_HEIGHT);
        float height = width / aspectRatio;
        
        self.adSize = CGSizeMake(width, height);
        
        [weakSelf.interstitial loadUsingSize:CGRectMake(0, 0, width, height)];
    });
}

- (BOOL)isReady {
    return self.interstitialIsReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    
    float aspectRatio = [self.provider.data.extra[YumiProviderExtraBaidu] floatValue];
    
    if (aspectRatio == 0) {
        [self.interstitial presentFromRootViewController:rootViewController];
        return ;
    }
    
    self.customInterView = [[UIView alloc] init];;
    [rootViewController.view addSubview:self.customInterView];
    
    [self.customInterView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
        make.center.equalTo(rootViewController.view);
        make.height.mas_equalTo(self.adSize.height);
        make.width.mas_equalTo(self.adSize.width);
    }];
    [rootViewController.view layoutIfNeeded];
    
    [self.interstitial presentFromView:self.customInterView];
    
}

#pragma mark - BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return self.provider.data.key1;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:interstitial adType:self.adType];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = NO;
    [self.delegate coreAdapter:self coreAd:interstitial didFailToLoad:@"Baidu ad load fail" adType:self.adType];
    
    [self clearInterstitial];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    self.interstitialIsReady = NO;
    [self.delegate coreAdapter:self didOpenCoreAd:interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:interstitial adType:self.adType];
}

- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason)reason {
    [self.delegate coreAdapter:self
                failedToShowAd:interstitial
                   errorString:@"Baidu ad failed to show"
                        adType:self.adType];
    [self clearInterstitial];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didClickCoreAd:interstitial adType:self.adType];
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    [self.delegate coreAdapter:self didCloseCoreAd:interstitial isCompletePlaying:NO adType:self.adType];
    
    [self clearInterstitial];
}

- (void)clearInterstitial {
    
    if (self.customInterView) {
        [self.customInterView removeFromSuperview];
        self.customInterView = nil;
    }
    
    if (self.interstitial) {
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
}

@end
