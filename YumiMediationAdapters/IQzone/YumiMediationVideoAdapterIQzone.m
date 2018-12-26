//
//  YumiMediationVideoAdapterIQzone.m
//  Pods
//
//  Created by generator on 26/12/2018.
//
//

#import "YumiMediationVideoAdapterIQzone.h"

@interface YumiMediationVideoAdapterIQzone ()

@end

@implementation YumiMediationVideoAdapterIQzone

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDIQzone
                                                      requestType:YumiMediationSDKAdRequest];
}

#pragma mark - YumiMediationVideoAdapter

- (nonnull id<YumiMediationVideoAdapter>)initWithProvider:(nonnull YumiMediationVideoProvider *)provider delegate:(nonnull id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];
    
    self.provider = provider;
    self.delegate = delegate;
    
    return self;
}

- (void)requestAd {
    // TODO: request ad
}

- (BOOL)isReady {
    // TODO: check if ready
    return YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    // TODO: present video ad
}


// TODO: implement third party sdk delegate and delegate to mediation sdk

@end
