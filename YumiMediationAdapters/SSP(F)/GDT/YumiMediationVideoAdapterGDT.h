//
//  YumiMediationVideoAdapterGDT.h
//  Pods
//
//  Created by 王泽永 on 2018/11/14.
//

#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationVideoAdapterGDT : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end

NS_ASSUME_NONNULL_END
