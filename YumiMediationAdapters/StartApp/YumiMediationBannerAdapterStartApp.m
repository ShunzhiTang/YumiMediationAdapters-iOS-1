//
//  YumiMediationBannerAdapterAdMob.m
//  Pods
//
//  Created by d shunzhiTang 19/6/2017.
//
//

#import "YumiMediationBannerAdapterStartApp.h"
#import "YumiMediationAdapterRegistry.h"
#import <StartApp/STABannerSize.h>
#import <StartApp/STABannerView.h>
#import <StartApp/StartApp.h>

@interface YumiMediationBannerAdapterStartApp () <STABannerDelegateProtocol, YumiMediationBannerAdapter>

@property (nonatomic, weak) id<YumiMediationBannerAdapterDelegate> delegate;
@property (nonatomic) YumiMediationBannerProvider *provider;
@property (nonatomic) STABannerView *bannerView;

@end

@implementation YumiMediationBannerAdapterStartApp

+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerBannerAdapter:self
                                                     forProviderID:@"10016"
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
    STABannerSize staAdSize = STA_AutoAdSize;
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
                                       withView:[strongSelf.delegate rootViewControllerForPresentingBannerView].view
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
