//
//  YumiMediationVideoAdapterVungle.h
//  Pods
//
//  Created by d on 24/6/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationVideoAdapterVungle : NSObject <YumiMediationVideoAdapter>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end