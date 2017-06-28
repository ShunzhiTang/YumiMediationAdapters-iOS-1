//
//  YumiMediationInterstitialAdapterApplovin.h
//  Pods
//
//  Created by generator on 28/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterApplovin : NSObject <YumiMediationInterstitialAdapter>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;

@end
