//
//  YumiMediationBannerAdapterFacebook.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterFacebook.h"
#import "YumiMediationAdapterConstructorRegistry.h"
#import <FBAudienceNetwork/FBAdView.h>

@implementation YumiMediationBannerAdapterFacebookConstructor

+ (void)load {
    [[YumiMediationAdapterConstructorRegistry registry] registerBannerAdapterConstructor:[self new]
                                                                           forProviderID:@"10007"
                                                                             requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)createAdapterWithProvider:(YumiMediationBannerProvider *)provider
                                                   delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    return [[YumiMediationBannerAdapterFacebook alloc] initWithYumiMediationAdProvider:provider delegate:delegate];
}

@end

@interface YumiMediationBannerAdapterFacebook () <FBAdViewDelegate>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) FBAdView *bannerView;

@end

@implementation YumiMediationBannerAdapterFacebook

- (instancetype)initWithYumiMediationAdProvider:(YumiMediationBannerProvider *)provider
                                       delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    
    FBAdSize adSize = isiPad ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    
    CGRect adframe = CGRectMake(0, 0, adSize.size.width , adSize.size.height);

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_bannerView) {
            self.bannerView = [[FBAdView alloc] initWithPlacementID:self.provider.data.key1 adSize:adSize rootViewController:[self.delegate rootViewControllerForPresentingBannerView]];
            self.bannerView.delegate  = self;
            self.bannerView.frame= adframe;
        }
        [self.bannerView loadAd];
        
        });
}


#pragma mark -  FBAdViewDelegate


#pragma mark - Getters
- (FBAdView *)bannerView {
    if (!_bannerView) {
        
        
    }

    return _bannerView;
}

@end
