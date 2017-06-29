//
//  YumiMediationInterstitialAdapterAdMob.h
//  Pods
//
//  Created by generator on 29/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterAdMob : NSObject <YumiMediationInterstitialAdapter>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;

@end
