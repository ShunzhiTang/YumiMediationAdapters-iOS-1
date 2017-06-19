//
//  YumiMediationBannerAdapterAdMob.h
//  Pods
//
//  Created by shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapter.h"
#import "YumiMediationBannerProvider.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationBannerAdapterAdMobConstructor : NSObject <YumiMediationBannerAdapterConstructor>

@end

@interface YumiMediationBannerAdapterAdMob : NSObject <YumiMediationBannerAdapter>

- (instancetype)initWithYumiMediationAdProvider:(YumiMediationBannerProvider *)provider
                                       delegate:(id<YumiMediationBannerAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
