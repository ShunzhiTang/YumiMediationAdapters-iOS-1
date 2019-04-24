//
//  YumiMediationinterstitialVideoAdapterMintegral.h
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2019/2/28.
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationinterstitialVideoAdapterMintegral : NSObject <YumiMediationCoreAdapter>

@property (nonatomic, weak) id<YumiMediationCoreAdapterDelegate> delegate;
@property (nonatomic) YumiMediationCoreProvider *provider;

@end

NS_ASSUME_NONNULL_END
