//
//  YumiMediationNativeAdapterFacebookConnector.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/2/13.
//

#import "YumiMediationNativeAdapterFacebookConnector.h"

@interface YumiMediationNativeAdapterFacebookConnector ()

@property (nonatomic) id<YumiMediationNativeAdapter> adapter;
@property (nonatomic, weak) id<YumiMediationNativeAdapterConnectorDelegate> connectorDelegate;
@property (nonatomic) FBNativeAd *fbNativeAd;

@end

@implementation YumiMediationNativeAdapterFacebookConnector

- (void)convertWithNativeData:(nullable FBNativeAd *)fbNativeAd
                  withAdapter:(id<YumiMediationNativeAdapter>)adapter
          disableImageLoading:(BOOL)disableImageLoading
            connectorDelegate:(id<YumiMediationNativeAdapterConnectorDelegate>)connectorDelegate {

    self.fbNativeAd = fbNativeAd;
    self.adapter = adapter;
    self.connectorDelegate = connectorDelegate;

    [self notifyMediatedNativeAdSuccessful];
}
- (void)notifyMediatedNativeAdSuccessful {
    YumiMediationNativeModel *nativeModel = [[YumiMediationNativeModel alloc] init];
    [nativeModel setValue:self forKey:@"unifiedNativeAd"];

    if ([self.connectorDelegate respondsToSelector:@selector(yumiMediationNativeAdSuccessful:)]) {
        [self.connectorDelegate yumiMediationNativeAdSuccessful:nativeModel];
    }
}
#pragma mark : YumiMediationUnifiedNativeAd
- (YumiMediationNativeAdImage *)icon {

    YumiMediationNativeAdImage *icon = [[YumiMediationNativeAdImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
    UIImage *graphicsImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [icon setValue:graphicsImg forKey:@"image"];

    return icon;
}
- (YumiMediationNativeAdImage *)coverImage {
    YumiMediationNativeAdImage *coverImage = [[YumiMediationNativeAdImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
    UIImage *graphicsImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [coverImage setValue:graphicsImg forKey:@"image"];

    return coverImage;
}
- (NSString *)title {
   // sdk version above 4.99 ,must dispaly advertiserName
    return self.fbNativeAd.advertiserName;
}
- (NSString *)desc {
    return self.fbNativeAd.bodyText;
}
- (NSString *)callToAction {
    return self.fbNativeAd.callToAction;
}
- (NSString *)appPrice {
    return nil;
}
- (NSString *)advertiser {
    return self.fbNativeAd.advertiserName;
}
- (NSString *)store {
    return nil;
}
- (NSString *)appRating {
    return nil;
}
- (NSString *)other {
    return nil;
}
- (id)data {
    return self.fbNativeAd;
}
- (id<YumiMediationNativeAdapter>)thirdparty {
    return self.adapter;
}
- (NSDictionary<NSString *, id> *)extraAssets {
    return nil;
}

@end
