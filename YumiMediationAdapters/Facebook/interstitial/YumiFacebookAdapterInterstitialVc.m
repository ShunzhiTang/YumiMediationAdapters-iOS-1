//
//  YumiFacebookAdapterInterstitialVc.m
//  Pods
//
//  Created by 甲丁乙_ on 2017/2/21.
//
//

#import "YumiFacebookAdapterInterstitialVc.h"

@interface YumiFacebookAdapterInterstitialVc ()

@end

@implementation YumiFacebookAdapterInterstitialVc

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
