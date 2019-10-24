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

typedef void(^VungleInitializeBlock)(BOOL isSuccessed);

@interface YumiMediationVungleInstance : NSObject <VungleSDKDelegate>

@property (nonatomic) NSMutableArray<YumiMediationInterstitialAdapterVungle *> *vungleInterstitialAdapters;
@property (nonatomic) NSMutableArray<YumiMediationVideoAdapterVungle *> *vungleVideoAdapters;

+ (YumiMediationVungleInstance *)sharedInstance;

- (void)vungleSDKDidInitializeCompleted:(VungleInitializeBlock)completed;

@end
