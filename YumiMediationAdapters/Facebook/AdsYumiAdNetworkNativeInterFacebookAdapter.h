//
//  AdsYumiAdNetworkNativeInterFacebookAdapter.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/20.
//
//

#import <YumiMediationSDK/AdsYuMIAdNetworkAdapter.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "YumiFacebookAdapterInterstitialVc.h"

@interface AdsYumiAdNetworkNativeInterFacebookAdapter : AdsYuMIAdNetworkAdapter<FBNativeAdDelegate,FBMediaViewDelegate>
{
    NSTimer * timer;
    BOOL isReading;
}
@property (strong, nonatomic) FBNativeAd *_nativeAd;
@property (strong, nonatomic)  UILabel *adStatusLabel;
@property (strong, nonatomic)  UIImageView *adIconImageView;
@property (weak, nonatomic)  FBMediaView *adCoverMediaView;
@property (strong, nonatomic)  UILabel *adTitleLabel;
@property (strong, nonatomic)  UILabel *adBodyLabel;
@property (strong, nonatomic)  UIButton *adCallToActionButton;
@property (strong, nonatomic)  UILabel *adSocialContextLabel;
@property (strong, nonatomic)  UILabel *sponsoredLabel;
@property (weak, nonatomic)  FBAdChoicesView *adChoicesView;
@property (strong, nonatomic)  UIView *adUIView;
//关闭按钮
@property (strong,nonatomic) UIButton *closeButton;
@property (strong,nonatomic) YumiFacebookAdapterInterstitialVc *intestitialView;

@end
