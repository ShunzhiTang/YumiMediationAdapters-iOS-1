//
//  YumiMediationInterstitialAdapterVungle.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationInterstitialAdapterVungle : NSObject <YumiMediationInterstitialAdapter>

@property (nonatomic, weak) id<YumiMediationInterstitialAdapterDelegate> delegate;
@property (nonatomic) YumiMediationInterstitialProvider *provider;

@end
