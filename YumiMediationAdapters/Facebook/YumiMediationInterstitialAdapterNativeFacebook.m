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

@interface YumiMediationInterstitialAdapterNativeFacebook()<FBNativeAdDelegate>

@property (strong, nonatomic) FBNativeAd *nativeAd;
@property (weak, nonatomic) FBAdChoicesView *adChoicesView;

@property (nonatomic)YumiFacebookAdapterInterstitialVc *interstitial;
@property (nonatomic ,assign) BOOL isAdReady;

@end

@implementation YumiMediationInterstitialAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerInterstitialAdapter:self
                                                           forProviderID:kYumiMediationAdapterIDFacebookNative
                                                             requestType:YumiMediationSDKAdRequest];
}

#pragma mark:  private  method
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
    
    YumiFacebookAdapterInterstitialVc *interstitialVc = [self getNibResourceFromCustomBundle:@"YumiFacebookInterstitialNativeAdapter" type:@"xib"];
    
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
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [nativeAd loadAd];
}

- (BOOL)isReady {
    return self.isAdReady;
}

- (void)present {
    
        [[self.delegate rootViewControllerForPresentingModalView]  presentViewController:self.interstitial
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
    [self.interstitial.adCoverMediaView setNativeAd:nativeAd];
    
    __weak typeof(self)  weakSelf = self;
    [self.nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        self.interstitial.adIconImageView.image = image;
        weakSelf.isAdReady = YES;
        
        [weakSelf.delegate adapter:weakSelf didReceiveInterstitialAd:weakSelf.interstitial];
    }];
    
    // Render native ads onto UIView
    self.interstitial.adTitleLabel.text = self.nativeAd.title;
    self.interstitial.adBodyLabel.text = self.nativeAd.body;
    self.interstitial.adSocialContextLabel.text = self.nativeAd.socialContext;
    self.interstitial.sponsoredLabel.text = @"Sponsored";
    [self.interstitial.adCallToActionButton setHidden:NO];
    [self.interstitial.adCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self.interstitial.adUIView
                      withViewController:[self.delegate rootViewControllerForPresentingModalView]];
    
    // Update AdChoices view
    self.interstitial.adChoicesView.nativeAd = nativeAd;
    self.interstitial.adChoicesView.corner = UIRectCornerTopRight;
    self.interstitial.adChoicesView.hidden = NO;
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    self.isAdReady = NO;
    [self.delegate adapter:self interstitialAd:self.interstitial didFailToReceive:[error localizedDescription]];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self closeFacebookIntestitial];
    
    [self.delegate adapter:self didClickInterstitialAd:self.interstitial on:CGPointZero];
}

@end
