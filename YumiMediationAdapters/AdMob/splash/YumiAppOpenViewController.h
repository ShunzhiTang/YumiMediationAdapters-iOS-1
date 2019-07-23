//
//  YumiAppOpenViewController.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/6/4.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiAppOpenViewController : UIViewController

@property (strong, nonatomic) GADAppOpenAd *appOpenAd;
@property (strong, nonatomic) GADAppOpenAdView *appOpenAdView;
@property (nonatomic, copy) void (^onViewControllerClosed)(void);
@property (nonatomic) UIView *bottomView;

@end

NS_ASSUME_NONNULL_END
