//
//  YumiAppOpenViewController.m
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2019/6/4.
//

#import "YumiAppOpenViewController.h"
#import <YumiMediationSDK/YumiTool.h>

@interface YumiAppOpenViewController ()

@end

@implementation YumiAppOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set backgroundColor
    self.view.backgroundColor = [UIColor blackColor];

    __weak typeof(self) weakSelf = self;
    GADAppOpenAdCloseHandler adCloseHandler = ^{

        // This is set by the AppDelegate
        weakSelf.onViewControllerClosed();
        // Close this view controller.
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    self.appOpenAdView = [[GADAppOpenAdView alloc] init];
    // Make sure to set the `GADAppOpenAdCloseHandler` and the `GADAppOpenAd` on your `GADAppOpenAdView`.
    self.appOpenAdView.adCloseHandler = adCloseHandler;
    self.appOpenAdView.appOpenAd = self.appOpenAd;

    [self layoutViews];
    //Fixed iOS 13 modalPresentationStyle
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (void)layoutViews {

    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat marginTop = 0;
    YumiTool *tool = [YumiTool sharedTool];

    if ([tool isiPhoneX] && [tool isInterfaceOrientationPortrait] && self.bottomView) {
        height = kIPHONEXHEIGHT - kIPHONEXSTATUSBAR - kIPHONEXHOMEINDICATOR;
        marginTop = kIPHONEXSTATUSBAR;
    }
    if ([tool isiPhoneXR] && [tool isInterfaceOrientationPortrait] && self.bottomView) {
        height = kIPHONEXRHEIGHT - kIPHONEXRSTATUSBAR - kIPHONEXRHOMEINDICATOR;
        marginTop = kIPHONEXRSTATUSBAR;
    }

    CGFloat defaultHeight = height * 0.85;

    CGFloat adHeight = height - self.bottomView.bounds.size.height > defaultHeight
                           ? height - self.bottomView.bounds.size.height
                           : defaultHeight;

    if (self.bottomView) {
        self.bottomView.frame =
            CGRectMake(0, marginTop + adHeight, self.bottomView.bounds.size.width, self.bottomView.bounds.size.height);

        [self.view addSubview:self.bottomView];
    }

    self.appOpenAdView.frame = CGRectMake(0, marginTop, [UIScreen mainScreen].bounds.size.width, adHeight);
    [self.view addSubview:self.appOpenAdView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
