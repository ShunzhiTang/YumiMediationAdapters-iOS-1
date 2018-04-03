//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterStartApp.h"
#import <StartApp/STABannerSize.h>
#import <StartApp/STABannerView.h>
#import <StartApp/StartApp.h>
#import <YumiMediationSDK/YumiMediationAdapterRegistry.h>

@interface YumiMediationBannerAdapterStartApp () <STABannerDelegateProtocol, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) STABannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterStartApp

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:kYumiMediationAdapterIDStartApp
                                                       requestType:YumiMediationSDKAdRequest];
}

- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate {
    self = [super init];

    self.provider = provider;
    self.delegate = delegate;

    return self;
}

#pragma mark - YumiMediationBannerAdapter
- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:YumiMediationBannerSelectableAdSize] integerValue] ==
        kYumiMediationAdViewBanner300x250) {
        [self.delegate adapter:self didFailToReceiveAd:@"StartApp not support kYumiMediationAdViewBanner300x250"];
        return;
    }
    STABannerSize staAdSize = isiPad ? STA_PortraitAdSize_768x90 : STA_PortraitAdSize_320x50;

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:autoAdSize] boolValue]) {
        staAdSize = STA_AutoAdSize;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
        sdk.appID = strongSelf.provider.data.key1;

        strongSelf.bannerView =
            [[STABannerView alloc] initWithSize:staAdSize
                                     autoOrigin:STAAdOrigin_Bottom
                                       withView:[strongSelf.delegate rootViewControllerForPresentingModalView].view
                                   withDelegate:strongSelf];
    });
}

#pragma mark - STABannerDelegateProtocol
- (void)didDisplayBannerAd:(STABannerView *)banner {
    [self.delegate adapter:self didReceiveAd:banner];
}
- (void)failedLoadBannerAd:(STABannerView *)banner withError:(NSError *)error {
    [self.delegate adapter:self didFailToReceiveAd:[error localizedDescription]];
}
- (void)didClickBannerAd:(STABannerView *)banner {
    [self.delegate adapter:self didClick:banner];
}

@end
