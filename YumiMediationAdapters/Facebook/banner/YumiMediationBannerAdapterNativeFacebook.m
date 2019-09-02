//
//  YumiMediationBannerAdapterNativeFacebook.m
//  Pods
//
//  Created by generator on 27/06/2017.
//
//

#import "YumiMediationBannerAdapterNativeFacebook.h"
#import "YumiMediationNativeFacebookBannerView.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiTool.h>

@interface YumiMediationBannerAdapterNativeFacebook () <YumiMediationBannerAdapter, FBNativeBannerAdDelegate>

@property (nonatomic) YumiMediationNativeFacebookBannerView *bannerView;
@property (nonatomic) FBNativeBannerAd *nativeAd;
@property (nonatomic) FBNativeBannerAd *currentNativeAd;
@property (nonatomic) FBAdChoicesView *adChoicesView;

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;
@property (nonatomic, assign) BOOL isSmartBanner;

@end

@implementation YumiMediationBannerAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDFacebookNative
                                                       requestType:YumiMediationSDKAdRequest];
}

#pragma mark : private method
- (YumiMediationNativeFacebookBannerView *)bannerViewFromCustomBundle {
    YumiTool *tool = [YumiTool sharedTool];
    NSBundle *YumiMediationFacebook = [tool resourcesBundleWithBundleName:@"YumiMediationFacebook"];
    YumiMediationNativeFacebookBannerView *bannerView =
        [YumiMediationFacebook loadNibNamed:@"YumiFacebookBannerNativeAdapter" owner:nil options:nil].firstObject;
    if (bannerView == nil) {
        NSLog(@"facebook Failed to load material");
    }

    return bannerView;
}

#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

    return self;
}

- (NSString *)networkVersion {
    return @"5.5.0";
}

- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart {
    self.bannerSize = adSize;
    self.isSmartBanner = isSmart;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if (self.bannerSize == kYumiMediationAdViewSmartBannerLandscape ||
        self.bannerSize == kYumiMediationAdViewSmartBannerPortrait) {
        [self.delegate adapter:self
            didFailToReceiveAd:@"Facebook-ys not support kYumiMediationAdViewSmartBannerLandscape & "
                               @"kYumiMediationAdViewSmartBannerPortrait"];
        return;
    }
    if (self.bannerSize == kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self didFailToReceiveAd:@"Facebook-ys not support kYumiMediationAdViewBanner300x250"];
        return;
    }
    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    CGRect adframe = CGRectMake(0, 0, viewSize.width, adSize.size.height);

    self.bannerView = [self bannerViewFromCustomBundle];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView.frame = adframe;

        strongSelf.nativeAd = [[FBNativeBannerAd alloc] initWithPlacementID:strongSelf.provider.data.key1];
        strongSelf.nativeAd.delegate = strongSelf;

        [strongSelf.nativeAd loadAd];
    });
}

#pragma mark - FBNativeBannerAdDegate
- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd {
    if (!self.bannerView) {
        return;
    }
    if (self.currentNativeAd) {
        // disconnect a FBNativeAd with the UIView you used to display the native ads.
        [self.currentNativeAd unregisterView];
    }

    self.currentNativeAd = nativeBannerAd;
    // associate a FBNativeAd with the UIView you will use to display the native ads.
    [self.currentNativeAd registerViewForInteraction:self.bannerView
                                            iconView:self.bannerView.adIconImageView
                                      viewController:[self.delegate rootViewControllerForPresentingModalView]];

    // Render native ads data  onto bannerView
    self.bannerView.adTitleLabel.text = self.currentNativeAd.advertiserName;
    self.bannerView.adSocialContextLabel.text = self.currentNativeAd.socialContext;
    [self.bannerView.adCallToActionButton setTitle:self.currentNativeAd.callToAction forState:UIControlStateNormal];
    // adChoicesView
    self.adChoicesView = [[FBAdChoicesView alloc] initWithNativeAd:self.currentNativeAd];
    self.adChoicesView.nativeAd = self.currentNativeAd;
    self.adChoicesView.corner = UIRectCornerTopRight;
    self.adChoicesView.hidden = NO;
    [self.bannerView.adUIView addSubview:self.adChoicesView];
    [self.adChoicesView updateFrameFromSuperview];

    [self.delegate adapter:self didReceiveAd:self.bannerView];
}

- (void)nativeBannerAdDidClick:(FBNativeBannerAd *)nativeBannerAd {
    [self.delegate adapter:self didClick:self.bannerView];
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

@end
