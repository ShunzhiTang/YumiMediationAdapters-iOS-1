//
//  YumiMediationInterstitialAdapterIronSource.h
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/10.
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterIronSource : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
