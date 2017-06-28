//
//  AdsYumiAdNetworkNativeAdFacebookAdapter.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/15.
//
//

#import "YumiMediationNativeFacebookBannerView.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>

@interface AdsYumiAdNetworkNativeAdFacebookAdapter : AdsYuMIAdNetworkAdapter <FBNativeAdDelegate> {
    BOOL isStop;
    NSTimer *timer;
    BOOL isReading;
}
@property (strong, nonatomic) YumiMediationNativeFacebookBannerView *bannerVC;
@property (strong, nonatomic) FBNativeAd *nativeAd;
@property (strong, nonatomic) UIView *AdUIView;
@property (strong, nonatomic) UIImageView *adIconImageView;
@property (strong, nonatomic) UILabel *adTitleLable;
@property (strong, nonatomic) UILabel *adSocialContext;
@property (strong, nonatomic) UIButton *adCallToActionButton;
@property (strong, nonatomic) FBAdChoicesView *adChoicesView;
@end
