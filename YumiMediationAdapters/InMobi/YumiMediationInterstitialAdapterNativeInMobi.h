//
//  YumiMediationInterstitialAdapterNativeInMobi.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/29.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterNativeInMobi : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
