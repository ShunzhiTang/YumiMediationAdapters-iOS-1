//
//  YumiMediationNativeAdapterFacebookConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/13.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterFacebookConnector : NSObject <YumiMediationUnifiedNativeAd,YumiMediationNativeAdapterConnectorMedia>

- (void)convertWithNativeData:(nullable FBNativeAd *)fbNativeAd
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@property (nonatomic) FBMediaView *mediaView;

@end

NS_ASSUME_NONNULL_END
