//
//  YumiAppOpenViewController.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/6/4.
//

#import "YumiAppOpenViewController.h"

@interface YumiAppOpenViewController ()

@end

@implementation YumiAppOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YumiAppOpenViewController *__weak weakSelf = self;
    GADAppOpenAdCloseHandler adCloseHandler = ^{
        // This block gets called when the ad is finished displaying,
        // or when the user explicitly closes the ad.
        YumiAppOpenViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // This is set by the AppDelegate
        strongSelf.onViewControllerClosed();
        // Close this view controller.
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    // Make sure to set the `GADAppOpenAdCloseHandler` and the `GADAppOpenAd`
    // on your `GADAppOpenAdView`.
    self.appOpenAdView.adCloseHandler = adCloseHandler;
    self.appOpenAdView.appOpenAd = self.appOpenAd;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
