//
//  YumiMediationNativeAdapterGDTConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/1.
//

#import "GDTUnifiedNativeAd.h"
#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterGDTConnector : NSObject <YumiMediationUnifiedNativeAd>

- (void)convertWithNativeData:(nullable GDTUnifiedNativeAdDataObject *)gdtNativeAdData
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@property (nonatomic) GDTUnifiedNativeAdView  *gdtNativeView;

@end

NS_ASSUME_NONNULL_END
