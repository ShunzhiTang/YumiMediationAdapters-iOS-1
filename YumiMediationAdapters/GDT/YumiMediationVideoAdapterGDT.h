//
//  YumiMediationVideoAdapterGDT.h
//  Pods
//
//  Created by 王泽永 on 2018/11/14.
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationVideoAdapterGDT : NSObject <YumiMediationVideoAdapter>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end

NS_ASSUME_NONNULL_END
