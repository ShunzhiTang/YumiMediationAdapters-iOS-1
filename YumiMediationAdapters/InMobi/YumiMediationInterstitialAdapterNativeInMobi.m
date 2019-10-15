//
//  YumiMediationInterstitialAdapterNativeInMobi.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/29.
//

#import "YumiMediationInterstitialAdapterNativeInMobi.h"
#import <InMobiSDK/InMobiSDK.h>
#import <YumiMediationSDK/YumiAdsWKCustomViewController.h>
#import <YumiMediationSDK/YumiBannerViewTemplateManager.h>
#import <YumiMediationSDK/YumiMediationGDPRManager.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeInMobi () <IMNativeDelegate, YumiAdsWKCustomViewControllerDelegate>

@property (nonatomic) IMNative *imnative;
@property (nonatomic) NSDictionary *imobeDict;
@property (nonatomic) YumiAdsWKCustomViewController *interstitial;

@property (nonatomic) YumiMediationTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic) YumiBannerViewTemplateManager *templateManager;
@property (nonatomic, assign) YumiMediationAdType adType;

@end

@implementation YumiMediationInterstitialAdapterNativeInMobi

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDInMobiNative
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark :private method
- (NSString *)resourceNamedFromCustomBundle:(NSString *)name {
    NSBundle *YumiMediationSDK = [[YumiTool sharedTool] resourcesBundleWithBundleName:@"YumiMediationSDK"];
    NSString *strPath = [YumiMediationSDK pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"];

    return strPath;
}

- (void)createCustomViewControllerWith:(CGFloat)width height:(CGFloat)height {
    CGRect inmobiFrame = CGRectMake(0, 0, width, height);

    NSDictionary *closeBtnFrame = @{
        @"closeButton_w" : @(self.provider.data.closeButton.clickAreaWidth),
        @"closeButton_h" : @(self.provider.data.closeButton.clickAreaHeight),
        @"closeImage_w" : @(self.provider.data.closeButton.pictureWidth),
        @"closeImage_h" : @(self.provider.data.closeButton.pictureHeight)
    };

    self.interstitial = [[YumiAdsWKCustomViewController alloc]
        initYumiAdsWKCustomViewControllerWith:inmobiFrame
                                    clickType:YumiAdsClickTypeOpenSystemSafari
                             closeBtnPosition:self.provider.data.closeButton.position
                                closeBtnFrame:closeBtnFrame
                                     logoType:YumiAdsLogoCommon
                                     delegate:self];
    self.interstitial.isNativeInterstitialGDT = NO;
}

#pragma mark - YumiMediationCoreAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    dispatch_async(dispatch_get_main_queue(), ^{
        // set gdpr
        YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;
        NSDictionary *consentDict = nil;
        if (gdprStatus == YumiMediationConsentStatusPersonalized) {
            consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(YES) };
        }
        if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
            consentDict = @{ IM_GDPR_CONSENT_AVAILABLE : @(NO) };
        }

        // Initialize InMobi SDK with your account ID
        [IMSdk initWithAccountID:provider.data.key1 consentDictionary:consentDict];
        [IMSdk setLogLevel:kIMSDKLogLevelNone];
    });
    return self;
}

- (NSString *)networkVersion {
    return @"7.4.0";
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (void)requestAd {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // update gdpr
        YumiMediationConsentStatus gdprStatus = [YumiMediationGDPRManager sharedGDPRManager].getConsentStatus;

        if (gdprStatus == YumiMediationConsentStatusPersonalized) {
            [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(YES) }];
        }
        if (gdprStatus == YumiMediationConsentStatusNonPersonalized) {
            [IMSdk updateGDPRConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @(NO) }];
        }

        weakSelf.imnative = [[IMNative alloc] initWithPlacementId:[self.provider.data.key2 longLongValue]];
        weakSelf.imnative.delegate = self;
        [weakSelf.imnative load];

    });
}

- (BOOL)isReady {

    return self.interstitial.isReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];

    // inmobi present
    [self.imnative recyclePrimaryView];
}

#pragma mark : - IMNativeDelegate

- (void)nativeDidFinishLoading:(IMNative *)native {

    if (!native || !native.customAdContent) {
        [self.delegate coreAdapter:self
                            coreAd:self.interstitial
                     didFailToLoad:@"Inmobi native no ad"
                            adType:self.adType];
        return;
    }

    if (native.customAdContent != nil) {
        NSData *data = [native.customAdContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        self.imobeDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (!self.imobeDict || ![self.imobeDict objectForKey:@"screenshots"]) {
        [self.delegate coreAdapter:self
                            coreAd:self.interstitial
                     didFailToLoad:@"Inmobi native no ad"
                            adType:self.adType];
        return;
    }

    NSUInteger width = [[[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"width"] integerValue];
    NSUInteger height = [[[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"height"] integerValue];
    NSString *url = [[self.imobeDict objectForKey:@"screenshots"] objectForKey:@"url"];
    NSString *clickUrl = [self.imobeDict objectForKey:@"landingURL"];

    if (!url || url.length == 0 || width == 0 || height == 0 || !clickUrl || clickUrl.length == 0) {
        [self.delegate coreAdapter:self
                            coreAd:self.interstitial
                     didFailToLoad:@"Inmobi native no ad"
                            adType:self.adType];
        return;
    }

    [self createCustomViewControllerWith:width height:height];

    NSString *interstitialPath = [self resourceNamedFromCustomBundle:@"cp-img"];

    NSData *interstitialData = [NSData dataWithContentsOfFile:interstitialPath];
    NSString *interstitialStr = [[NSString alloc] initWithData:interstitialData encoding:NSUTF8StringEncoding];

    interstitialStr = [NSString stringWithFormat:interstitialStr, @"100%", @"100%", @"100%", @"100%", clickUrl, url];

    [self.interstitial loadHTMLString:interstitialStr];
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error {
    [self.delegate coreAdapter:self
                        coreAd:self.interstitial
                 didFailToLoad:error.localizedDescription
                        adType:self.adType];
    ;
}

- (void)nativeWillPresentScreen:(IMNative *)native {
}
- (void)nativeDidPresentScreen:(IMNative *)native {
}
- (void)nativeWillDismissScreen:(IMNative *)native {
}
- (void)nativeDidDismissScreen:(IMNative *)native {
}
- (void)userWillLeaveApplicationFromNative:(IMNative *)native {
}
- (void)nativeAdImpressed:(IMNative *)native {
}

#pragma mark : YumiAdsWKCustomViewControllerDelegate
- (void)yumiAdsWKCustomViewControllerDidReceivedAd:(UIViewController *)viewController {
    [self.delegate coreAdapter:self
             didReceivedCoreAd:self.interstitial
             interstitialFrame:CGRectZero
                withTemplateID:(int)self.currentID
                        adType:self.adType];
}

- (void)yumiAdsWKCustomViewController:(UIViewController *)viewController didFailToReceiveAdWithError:(NSError *)error {
    [self.delegate coreAdapter:self
                        coreAd:self.interstitial
                 didFailToLoad:error.localizedDescription
                        adType:self.adType];
    ;
}

- (void)didClickOnYumiAdsWKCustomViewController:(UIViewController *)viewController point:(CGPoint)point {
    // inmobi
    [self.imnative reportAdClickAndOpenLandingPage];

    [self.delegate coreAdapter:self
                didClickCoreAd:self.interstitial
                            on:point
                withTemplateID:(int)self.currentID
                        adType:self.adType];
}

- (void)yumiAdsWKCustomViewControllerDidPresent:(UIViewController *)viewController {

    [self.delegate coreAdapter:self didOpenCoreAd:self.interstitial adType:self.adType];
    [self.delegate coreAdapter:self didStartPlayingAd:self.interstitial adType:self.adType];
}

- (void)yumiAdsWKCustomViewControllerDidClosed:(UIViewController *)viewController {
    [self.delegate coreAdapter:self didCloseCoreAd:self.interstitial isCompletePlaying:NO adType:self.adType];
}

@end
