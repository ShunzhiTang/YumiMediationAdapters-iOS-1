//
//  YumiMediationVideoAdapterIronSource.h
//  Pods
//
//  Created by generator on 26/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationVideoAdapterIronSource : NSObject <YumiMediationVideoAdapter>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end
