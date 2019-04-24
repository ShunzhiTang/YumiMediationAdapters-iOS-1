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

@property (nonatomic) NSMutableArray<YumiMediationInterstitialAdapterVungle *> *vungleInterstitialAdapters;
@property (nonatomic) NSMutableArray<YumiMediationVideoAdapterVungle *> *vungleVideoAdapters;

+ (YumiMediationVungleInstance *)sharedInstance;
- (void)videoVungleSDKFailedToInitializeWith:(YumiMediationVideoAdapterVungle *)videoAdapter;
- (void)interstitialVungleSDKFailedToInitializeWith:(YumiMediationInterstitialAdapterVungle *)interstitialAdapter;

// adType
@property (nonatomic, assign) YumiMediationAdType adType;

@end
