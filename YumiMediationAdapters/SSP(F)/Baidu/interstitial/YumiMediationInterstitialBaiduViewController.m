//
//  YumiMediationInterstitialBaiduViewController.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/7/17.
//

#import "YumiMediationInterstitialBaiduViewController.h"
#import <YumiAdSDK/YumiMasonry.h>

@interface YumiMediationInterstitialBaiduViewController ()

@property (nonatomic) UIView *customInterView;

@end

@implementation YumiMediationInterstitialBaiduViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //Fixed iOS 13 modalPresentationStyle
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)presentBaiduInterstitial:(BaiduMobAdInterstitial *)interstitial adSize:(CGSize)adSize {

    self.customInterView = [[UIView alloc] init];
    ;
    [self.view addSubview:self.customInterView];

    [self.customInterView mas_makeConstraints:^(YumiMASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.mas_equalTo(adSize.height);
        make.width.mas_equalTo(adSize.width);
    }];
    [self.view layoutIfNeeded];

    [interstitial presentFromView:self.customInterView];
}

@end
