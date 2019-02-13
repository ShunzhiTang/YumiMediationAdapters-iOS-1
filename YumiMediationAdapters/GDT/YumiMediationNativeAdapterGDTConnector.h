//
//  YumiMediationNativeAdapterGDTConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/1.
//

#import "GDTNativeAd.h"
#import "YumiMediationAdapterRegistry.h"
#import "YumiMediationUnifiedNativeAd.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterGDTConnector : NSObject <YumiMediationUnifiedNativeAd>

- (void)convertWithNativeData:(nullable GDTNativeAdData *)gdtNativeAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@end

NS_ASSUME_NONNULL_END
