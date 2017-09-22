//
//  YumiMediationVideoAdapterCentrixlink.h
//  YumiMediationAdapters
//
//  Created by ShunZhi Tang on 2017/9/22.
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationVideoAdapterCentrixlink : NSObject <YumiMediationVideoAdapter>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end
