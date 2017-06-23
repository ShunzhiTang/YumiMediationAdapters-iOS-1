//
//  YumiMediationVideoAdapterUnity.h
//  Pods
//
//  Created by d on 23/6/2017.
//
//

#import "YumiMediationAdapterRegistry.h"
#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>

@interface YumiMediationVideoAdapterUnity : NSObject <YumiMediationVideoAdapter, UnityAdsDelegate>

@property (nonatomic, weak) id<YumiMediationVideoAdapterDelegate> delegate;
@property (nonatomic) YumiMediationVideoProvider *provider;

@end
