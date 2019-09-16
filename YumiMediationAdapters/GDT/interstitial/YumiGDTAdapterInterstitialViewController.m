//
//  YumiGDTAdapterInterstitialViewController.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2018/8/20.
//

#import "YumiGDTAdapterInterstitialViewController.h"

@interface YumiGDTAdapterInterstitialViewController ()

@end

@implementation YumiGDTAdapterInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Fixed iOS 13 modalPresentationStyle
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (IBAction)closeInterstitial:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
