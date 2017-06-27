//
//  YumiMediationBannerAdapterNativeFacebook.m
//  Pods
//
//  Created by generator on 27/06/2017.
//
//

#import "YumiMediationBannerAdapterNativeFacebook.h"
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterNativeFacebook ()<YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;

@end

@implementation YumiMediationBannerAdapterNativeFacebook

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10049"
                                                       requestType:YumiMediationSDKAdRequest];
}
#pragma mark - YumiMediationBannerAdapter
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.delegate = delegate;
    self.provider = provider;

 	// TODO: setup code
    return self;
}

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
	// TODO: request ad
}

// TODO: implement third party sdk delegate and delegate to mediation sdk

@end
