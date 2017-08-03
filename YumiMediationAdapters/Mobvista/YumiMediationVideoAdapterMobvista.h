//
//  YumiMediationVideoAdapterMobvista.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/8/3.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationVideoAdapterMobvista : NSObject<YumiMediationVideoAdapter>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end
