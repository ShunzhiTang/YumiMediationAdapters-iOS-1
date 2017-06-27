//
//  YumiMediationInterstitialAdapterAdMob.h
//  Pods
//
//  Created by 魏晓磊 on 17/6/21.
//
//

#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <Foundation/Foundation.h>

@interface YumiMediationInterstitialAdapterAdMob : NSObject <YumiMediationInterstitialAdapter>
    
@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;

@end
