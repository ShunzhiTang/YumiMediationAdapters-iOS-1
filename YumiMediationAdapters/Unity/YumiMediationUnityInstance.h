//
//  YumiMediationUnityInstance.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2017/11/22.
//

#import "YumiMediationInterstitialAdapterUnity.h"
#import "YumiMediationVideoAdapterUnity.h"
#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>

typedef void(^UnityInitializedBlock)(BOOL isSuccessed);

@interface YumiMediationUnityInstance : NSObject <UnityAdsExtendedDelegate>

+ (YumiMediationUnityInstance *)sharedInstance;

@property (nonatomic) NSMutableDictionary<NSString *, id<YumiMediationCoreAdapter>> *adaptersDict;

- (NSString *)getAdapterKeyWith:(NSString *)placementId adType:(YumiMediationAdType)adType;

- (void)unitySDKDidInitializeCompleted:(UnityInitializedBlock)completed;

@end
