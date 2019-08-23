//
//  YumiMediationInterstitialAdapterNativeFacebook.m
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/21.
//
//

#import "YumiMediationInterstitialAdapterNativeFacebook.h"
#import "YumiFacebookAdapterInterstitialVc.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationInterstitialAdapterNativeFacebook () <FBNativeAdDelegate, FBMediaViewDelegate>

@property (nonatomic) FBNativeAd *nativeAd;
@property (nonatomic) YumiFacebookAdapterInterstitialVc *interstitial;
@property (nonatomic, assign) BOOL isAdReady;
@property (nonatomic, assign) YumiMediationAdType adType;
@property (nonatomic) UIViewController *rootViewController;

@end

@implementation YumiMediationInterstitialAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerCoreAdapter:self
                                                   forProviderID:kYumiMediationAdapterIDFacebookNative
                                                     requestType:YumiMediationSDKAdRequest
                                                          adType:YumiMediationAdTypeInterstitial];
}

#pragma mark :  private  method
- (YumiFacebookAdapterInterstitialVc *)getNibResourceFromCustomBundle:(NSString *)name type:(NSString *)type {
    [FBMediaView class];
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"YumiMediationFacebook" withExtension:@"bundle"];
    NSBundle *YumiMediationFacebook = [NSBundle bundleWithURL:bundleURL];

    YumiFacebookAdapterInterstitialVc *vc = [YumiMediationFacebook loadNibNamed:name owner:nil options:nil].firstObject;
    if (vc == nil) {
        NSLog(@"facebook 加载素材失败");
    }
    return vc;
}

- (YumiFacebookAdapterInterstitialVc *)createInterstitialVc {

    YumiFacebookAdapterInterstitialVc *interstitialVc =
        [self getNibResourceFromCustomBundle:@"YumiFacebookInterstitialNativeAdapter" type:@"xib"];

    [interstitialVc.closeButton addTarget:self
                                   action:@selector(closeFacebookIntestitial)
                         forControlEvents:UIControlEventTouchUpInside];
    return interstitialVc;
}

- (void)closeFacebookIntestitial {
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];

    [self.delegate coreAdapter:self didCloseCoreAd:nil isCompletePlaying:NO adType:self.adType];
    self.interstitial = nil;
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationCoreAdapter>)initWithProvider:(YumiMediationCoreProvider *)provider
                                        delegate:(id<YumiMediationCoreAdapterDelegate>)delegate
                                          adType:(YumiMediationAdType)adType {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;
    self.adType = adType;

    return self;
}

- (void)updateProviderData:(YumiMediationCoreProvider *)provider {
    self.provider = provider;
}

- (NSString *)networkVersion {
    return @"5.3.2";
}

- (void)requestAd {
    self.rootViewController = [[YumiTool sharedTool] topMostController];
    self.isAdReady = NO;
    self.interstitial = [self createInterstitialVc];
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.data.key1];
    nativeAd.delegate = self;
    [nativeAd loadAd];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    __weak __typeof(self) weakSelf = self;
    [rootViewController presentViewController:self.interstitial
                                     animated:YES
                                   completion:^{
                                       [weakSelf.delegate coreAdapter:weakSelf didOpenCoreAd:nil adType:weakSelf.adType];
                                       [weakSelf.delegate coreAdapter:weakSelf didStartPlayingAd:nil adType:weakSelf.adType];
                                   }];
}

#pragma mark FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }

    self.nativeAd = nativeAd;

    // Create native UI using the ad metadata.
    self.interstitial.adCoverMediaView.delegate = self;

    // Render native ads onto UIView
    self.interstitial.adTitleLabel.text = self.nativeAd.advertiserName;
    self.interstitial.adBodyLabel.text = self.nativeAd.bodyText;
    self.interstitial.adSocialContextLabel.text = self.nativeAd.socialContext;
    self.interstitial.sponsoredLabel.text = self.nativeAd.sponsoredTranslation;
    [self.interstitial.adCallToActionButton setHidden:NO];
    [self.interstitial.adCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];

    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [self.nativeAd registerViewForInteraction:self.interstitial.adUIView
                                    mediaView:self.interstitial.adCoverMediaView
                                     iconView:self.interstitial.adIconImageView
                               viewController:self.rootViewController];

    // Update AdChoices view
    self.interstitial.adChoicesView.nativeAd = nativeAd;
    self.interstitial.adChoicesView.corner = UIRectCornerTopRight;
    self.interstitial.adChoicesView.hidden = NO;

    self.isAdReady = YES;
    [self.delegate coreAdapter:self didReceivedCoreAd:self.interstitial adType:self.adType];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    self.isAdReady = NO;
    [self.delegate coreAdapter:self
                        coreAd:self.interstitial
                 didFailToLoad:[error localizedDescription]
                        adType:self.adType];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
    [self.delegate coreAdapter:self didClickCoreAd:self.interstitial adType:self.adType];

    [self closeFacebookIntestitial];
}
@end
