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
   
}

- (IBAction)closeInterstitial:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
