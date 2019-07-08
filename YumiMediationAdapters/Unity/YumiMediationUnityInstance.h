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

@interface YumiMediationUnityInstance : NSObject <UnityAdsExtendedDelegate>

//@property (nonatomic) YumiMediationInterstitialAdapterUnity *unityInterstitialAdapter;
//@property (nonatomic) YumiMediationVideoAdapterUnity *unityVideoAdapter;

+ (YumiMediationUnityInstance *)sharedInstance;

@property (nonatomic) NSMutableDictionary<NSString *,id<YumiMediationCoreAdapter>>  *adaptersDict;

- (NSString *)getAdapterKeyWith:(NSString *)placementId adType:(YumiMediationAdType)adType;

@end
