//
//  YumiMediationVideoAdapterBaidu.h
//  Pods
//
//  Created by generator on 26/09/2018.
//
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationVideoAdapterBaidu : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end
