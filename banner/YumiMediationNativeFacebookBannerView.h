//
//  YumiMediationNativeFacebookBannerView.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/22.
//
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <UIKit/UIKit.h>

@interface YumiMediationNativeFacebookBannerView : UIView
@property (weak, nonatomic) IBOutlet FBAdIconView *adIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *adTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *adCallToActionButton;
@property (strong, nonatomic) IBOutlet UILabel *adSocialContextLabel;
@property (strong, nonatomic) IBOutlet UIView *adUIView;
@end
