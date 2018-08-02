//
//  YumiFacebookAdapterInterstitialVc.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/21.
//
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface YumiFacebookAdapterInterstitialVc : UIViewController

@property (weak, nonatomic) IBOutlet FBAdIconView *adIconImageView;
@property (weak, nonatomic) IBOutlet FBMediaView *adCoverMediaView;
@property (strong, nonatomic) IBOutlet UILabel *adTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *adBodyLabel;
@property (strong, nonatomic) IBOutlet UIButton *adCallToActionButton;
@property (strong, nonatomic) IBOutlet UILabel *adSocialContextLabel;
@property (strong, nonatomic) IBOutlet UILabel *sponsoredLabel;
@property (weak, nonatomic) IBOutlet FBAdChoicesView *adChoicesView;

@property (strong, nonatomic) IBOutlet UIView *adUIView;

@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@end
