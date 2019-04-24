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

@interface YumiMediationUnityInstance : NSObject <UnityAdsDelegate>

@property (nonatomic) YumiMediationInterstitialAdapterUnity *unityInterstitialAdapter;
@property (nonatomic) YumiMediationVideoAdapterUnity *unityVideoAdapter;
@property (nonatomic, assign) YumiMediationAdType adType;

+ (YumiMediationUnityInstance *)sharedInstance;

@end
