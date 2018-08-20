//
//  YumiGDTAdapterInterstitialViewController.h
//  YumiMediationAdapters
//
//  Created by Michael Tang on 2018/8/20.
//

#import <UIKit/UIKit.h>

typedef void (^CloseBlock)(void);

@interface YumiGDTAdapterInterstitialViewController : UIViewController

@property (nonatomic, copy) CloseBlock closeBlock;

@end
