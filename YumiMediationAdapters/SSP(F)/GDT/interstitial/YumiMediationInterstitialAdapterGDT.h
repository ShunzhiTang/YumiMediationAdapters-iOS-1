//
//  YumiMediationInterstitialAdapterGDT.h
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterGDT : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
