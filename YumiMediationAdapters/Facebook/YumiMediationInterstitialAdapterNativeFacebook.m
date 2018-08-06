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

@interface YumiMediationInterstitialAdapterNativeFacebook () <FBNativeAdDelegate, FBMediaViewDelegate>

@property (nonatomic) FBNativeAd *nativeAd;
@property (nonatomic) YumiFacebookAdapterInterstitialVc *interstitial;
@property (nonatomic, assign) BOOL isAdReady;

@end

@implementation YumiMediationInterstitialAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebookNative
                                                             requestType:YumiMediationSDKAdRequest];
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
    [[self.delegate rootViewControllerForPresentingModalView] dismissViewControllerAnimated:YES completion:nil];

    [self.delegate adapter:self willDismissScreen:self.interstitial];
    self.interstitial = nil;
}

#pragma mark - YumiMediationInterstitialAdapter
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

- (void)requestAd {
    self.isAdReady = NO;

    self.interstitial = [self createInterstitialVc];

    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.data.key1];
    nativeAd.delegate = self;

    [nativeAd loadAd];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)present {

    [[self.delegate rootViewControllerForPresentingModalView] presentViewController:self.interstitial
                                                                           animated:YES
                                                                         completion:^{
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
                               viewController:[self.delegate rootViewControllerForPresentingModalView]];

    // Update AdChoices view
    self.interstitial.adChoicesView.nativeAd = nativeAd;
    self.interstitial.adChoicesView.corner = UIRectCornerTopRight;
    self.interstitial.adChoicesView.hidden = NO;

    self.isAdReady = YES;
    [self.delegate adapter:self didReceiveInterstitialAd:self.interstitial];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    self.isAdReady = NO;
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    
    [self.delegate adapter:self didClickInterstitialAd:self.interstitial on:CGPointZero];
    
    [self closeFacebookIntestitial];
}
@end
