//
//  YumiMediationNativeAdapterGDTConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/1.
//

#import "GDTUnifiedNativeAd.h"
#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>
#import <YumiAdSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterGDTConnector : NSObject <YumiMediationUnifiedNativeAd>

- (void)convertWithNativeData:(id)gdtAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@property (nonatomic) GDTUnifiedNativeAdView *gdtNativeView;

@end

NS_ASSUME_NONNULL_END
