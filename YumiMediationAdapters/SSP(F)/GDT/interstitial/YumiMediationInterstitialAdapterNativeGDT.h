//
//  YumiMediationInterstitialAdapterNativeGDT.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterNativeGDT : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
