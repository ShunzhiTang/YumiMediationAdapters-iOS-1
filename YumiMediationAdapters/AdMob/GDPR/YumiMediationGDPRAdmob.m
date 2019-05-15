//
//  YumiMediationGDPRAdmob.m
//  Pods
//
//  Created by 王泽永 on 2019/5/15.
//

#import "YumiMediationGDPRAdmob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationConstants.h>

@interface YumiMediationGDPRAdmob ()
@property (nonatomic, weak) id<YumiMediationGDPRdelegate> delegate;
@end

@implementation YumiMediationGDPRAdmob
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDAdMob
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationGDPRAdapter>)initWithDelegate:(id<YumiMediationGDPRdelegate>)delegate {
    self = [super init];
    
    self.delegate = delegate;
    return self;
}

- (void)updateNetworksConsentStatus:(YumiGDPRStatus)gdprStatus {
    GADRequest *request = [GADRequest request];
    GADExtras *extras = [[GADExtras alloc] init];
    
    if (gdprStatus == YumiConsentStatusPersonalized) {
        extras.additionalParameters = @{@"npa": @"0"};
    }
    if (gdprStatus == YumiConsentStatusNonPersonalized) {
        extras.additionalParameters = @{@"npa": @"1"};
    }
    if (gdprStatus == YumiConsentStatusUnknown) {
        extras.additionalParameters = @{@"npa": @"0"};
    }
    [request registerAdNetworkExtras:extras];
    
    [self.delegate updateConsentStatusSuccessWithgdprAdapter:self];
}

@end
