//
//  YumiMediationInterstitialBaiduViewController.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/7/17.
//

#import <UIKit/UIKit.h>
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationInterstitialBaiduViewController : UIViewController

- (void)presentBaiduInterstitial:(BaiduMobAdInterstitial *) interstitial adSize:(CGSize)adSize;

@end

NS_ASSUME_NONNULL_END
