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

@interface YumiMediationBannerAdapterNativeFacebook () <YumiMediationBannerAdapter, FBNativeAdDelegate>

@property (nonatomic) YumiMediationNativeFacebookBannerView *bannerView;
@property (nonatomic) FBNativeAd *nativeAd;
@property (nonatomic) FBNativeAd *currentNativeAd;
@property (nonatomic) FBAdChoicesView *adChoicesView;

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

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

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:YumiMediationBannerSelectableAdSize] integerValue] == kYumiMediationAdViewBanner300x250) {
        adSize = kFBAdSizeHeight250Rectangle;
    }
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

        strongSelf.nativeAd = [[FBNativeAd alloc] initWithPlacementID:strongSelf.provider.data.key1];
        strongSelf.nativeAd.delegate = strongSelf;
        strongSelf.nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;

        [strongSelf.nativeAd loadAd];
    });
}

#pragma mark - FBNativeAdDelegate
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    if (!self.bannerView) {
        return;
    }

    if (self.currentNativeAd) {
        // disconnect a FBNativeAd with the UIView you used to display the native ads.
        [self.currentNativeAd unregisterView];
    }

    self.currentNativeAd = nativeAd;
    // associate a FBNativeAd with the UIView you will use to display the native ads.
    [self.currentNativeAd registerViewForInteraction:self.bannerView.adUIView
                                  withViewController:[self.delegate rootViewControllerForPresentingModalView]];
    __weak typeof(self) weakSelf = self;
    [self.currentNativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.bannerView.adIconImageView.image = image;
    }];

    // Render native ads data  onto bannerView
    self.bannerView.adTitleLabel.text = self.currentNativeAd.title;
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

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self.delegate adapter:self didClick:self.bannerView];
}

@end
