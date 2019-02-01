//
//  YumiMediationNativeAdapterGDTConnector.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/1.
//

#import <Foundation/Foundation.h>
#import "YumiMediationUnifiedNativeAd.h"
#import "YumiMediationAdapterRegistry.h"
#import "GDTNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeAdapterGDTConnector : NSObject<YumiMediationUnifiedNativeAd>

- (nullable instancetype)initWithYumiNativeConnector:(nullable GDTNativeAdData *)gdtNativeAdData
                                         withAdapter:(id<YumiMediationNativeAdapter>)adapter
                                 shouldDownloadImage:(BOOL)shouldDownloadImage;
@property (nonatomic ,strong) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;

@end

NS_ASSUME_NONNULL_END
