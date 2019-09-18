//
//  YumiMediationInterstitialAdapterPlayableAds.h
//  Pods
//
//  Created by generator on 22/01/2018.
//
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterPlayableAds : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
