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
#import <YumiCommon/YumiTool.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterNativeFacebook () <YumiMediationBannerAdapter, FBNativeAdDelegate>

@property (nonatomic) YumiMediationNativeFacebookBannerView *bannerView;
@property (nonatomic) FBNativeAd *nativeAd;
@property (nonatomic) FBAdChoicesView *adChoicesView;

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@end

@implementation YumiMediationBannerAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10049"
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

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    CGRect adframe = CGRectMake(0, 0, viewSize.width, adSize.size.height);

    self.bannerView = [self bannerViewFromCustomBundle];
    self.bannerView.frame = adframe;

    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:self.provider.data.key1];
    nativeAd.delegate = self;
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;

    [nativeAd loadAd];
}

#pragma mark - FBNativeAdDelegate
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    if (!self.bannerView) {
        return;
    }

    if (self.nativeAd) {
        // disconnect a FBNativeAd with the UIView you used to display the native ads.
        [self.nativeAd unregisterView];
    }

    self.nativeAd = nativeAd;
    // associate a FBNativeAd with the UIView you will use to display the native ads.
    [nativeAd registerViewForInteraction:self.bannerView.adUIView
                      withViewController:[self.delegate rootViewControllerForPresentingBannerView]];
    __weak typeof(self) weakSelf = self;
    [self.nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView.adIconImageView.image = image;
    }];

    // Render native ads data  onto bannerView
    self.bannerView.adTitleLabel.text = self.nativeAd.title;
    self.bannerView.adSocialContextLabel.text = self.nativeAd.socialContext;
    [self.bannerView.adCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    // adChoicesView
    self.adChoicesView = [[FBAdChoicesView alloc] initWithNativeAd:self.nativeAd];
    self.adChoicesView.nativeAd = nativeAd;
    self.adChoicesView.corner = UIRectCornerTopRight;
    self.adChoicesView.hidden = NO;
    [self.bannerView.adUIView addSubview:self.adChoicesView];
    [self.adChoicesView updateFrameFromSuperview];

    [self.delegate adapter:self didReceiveAd:self.bannerView];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self.delegate adapter:self didClick:self.bannerView];
}

@end
