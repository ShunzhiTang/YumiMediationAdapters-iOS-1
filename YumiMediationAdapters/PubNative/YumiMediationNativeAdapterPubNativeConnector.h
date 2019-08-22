//
//  YumiMediationNativeAdapterPubNativeConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/8/13.
//

#import <Foundation/Foundation.h>
#import <HyBid/HyBid.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterPubNativeConnector
    : NSObject <YumiMediationUnifiedNativeAd, YumiMediationNativeAdapterConnectorMedia>

- (void)convertWithNativeData:(nullable HyBidNativeAd *)nativeObject
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;
@end

NS_ASSUME_NONNULL_END
