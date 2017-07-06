//
//  YumiMediationInterstitialAdapterNativeGDT.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/6.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterNativeGDT : NSObject<YumiMediationInterstitialAdapter>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;

@end
