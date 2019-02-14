//
//  YumiMediationNativeAdapterBaiduConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>
#import <YumiMediationSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterBaiduConnector : NSObject <YumiMediationUnifiedNativeAd>

- (void)convertWithNativeData:(nullable BaiduMobAdNativeAdObject *)nativeObject
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@end

NS_ASSUME_NONNULL_END
