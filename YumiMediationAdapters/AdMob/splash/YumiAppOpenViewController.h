//
//  YumiAppOpenViewController.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiAppOpenViewController : UIViewController

@property(strong, nonatomic) GADAppOpenAd* appOpenAd;
@property(strong, nonatomic) IBOutlet GADAppOpenAdView* appOpenAdView;
@property(nonatomic, copy) void (^onViewControllerClosed)(void);

@property (unsafe_unretained, nonatomic) IBOutlet UIView *bottomView;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *adViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewTopConstraint;


@end

NS_ASSUME_NONNULL_END
