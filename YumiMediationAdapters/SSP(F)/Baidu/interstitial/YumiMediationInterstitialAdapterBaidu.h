//
//  YumiMediationInterstitialAdapterBaidu.h
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterBaidu : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
