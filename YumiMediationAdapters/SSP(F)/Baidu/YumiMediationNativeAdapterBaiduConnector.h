//
//  YumiMediationNativeAdapterBaiduConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/14.
//

#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeVideoView.h>
#import <Foundation/Foundation.h>
#import <YumiAdSDK/YumiMediationAdapterRegistry.h>
#import <YumiAdSDK/YumiMediationUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterBaiduConnector
    : NSObject <YumiMediationUnifiedNativeAd, YumiMediationNativeAdapterConnectorMedia>

- (void)convertWithNativeData:(nullable BaiduMobAdNativeAdObject *)nativeObject
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate;

@property (nonatomic) BaiduMobAdNativeVideoView *videoView;

@end

NS_ASSUME_NONNULL_END
