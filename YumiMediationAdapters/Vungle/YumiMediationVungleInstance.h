//
//  YumiMediationVungleInstance.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/12/15.
//

#import "YumiMediationInterstitialAdapterVungle.h"
#import "YumiMediationVideoAdapterVungle.h"
#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>

@interface YumiMediationVungleInstance : NSObject <VungleSDKDelegate>

@property (nonatomic) YumiMediationInterstitialAdapterVungle *vungleInterstitialAdapter;
@property (nonatomic) YumiMediationVideoAdapterVungle *vungleVideoAdapter;
+ (YumiMediationVungleInstance *)sharedInstance;

@end
