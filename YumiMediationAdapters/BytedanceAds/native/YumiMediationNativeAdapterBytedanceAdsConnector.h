//
//  YumiMediationNativeAdapterBytedanceAdsConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on  23/05/2019.
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterBytedanceAdsConnector
    : NSObject <YumiMediationUnifiedNativeAd, YumiMediationNativeAdapterConnectorMedia>

- (void)convertWithNativeData:(nullable BUNativeAd *)buNativeAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@property (nonatomic) BUNativeAdRelatedView *nativeAdRelatedView;

@end

NS_ASSUME_NONNULL_END
