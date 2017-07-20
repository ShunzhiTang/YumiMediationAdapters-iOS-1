//
//  YumiMediationStreamAdapterYumi.m
//  Pods
//
//  Created by 魏晓磊 on 2017/7/10.
//
//

#import "YumiMediationStreamAdapterYumi.h"
#import <YUMINativeSDK/YUMINativeAdRequest.h>
#import <YUMINativeSDK/YUMINativeAdRequestDelegate.h>
#import <YumiMediationSDK/YUMIStreamModel.h>

@interface YumiMediationStreamAdapterYumi () <YUMINativeAdRequestDelegate>

@property (nonatomic, assign) BOOL isReading;
@property (nonatomic) YUMINativeAdRequest *nativeAd;
@property (nonatomic) NSMutableArray *modelArry;
@property (nonatomic) NSTimer *timer;

@end

@implementation YumiMediationStreamAdapterYumi

+ (NSString *)StreamRegister {
    return YuMIStreamNetworkAdNative;
}

+ (void)load {
    [[YUMIStreamSDKAdNetworkRegister sharedRegister] registerStreamClass:self];
}

- (void)getStream:(NSString *)numbers {

    [self startStream];

    NSTimeInterval interval = [self.streamProvider.outTime doubleValue];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval ?: 8
                                                  target:self
                                                selector:@selector(timeOutTimer)
                                                userInfo:nil
                                                 repeats:NO];
    self.nativeAd = [[YUMINativeAdRequest alloc] init];
    self.nativeAd.mydelegate = self;
    [self.nativeAd requestNativeAdWithAppKey:self.streamProvider.key1
                                     Channel:@""
                                 PlacementID:self.streamProvider.key2
                                      AdType:NativeNewsStream
                                    plcmtcnt:[numbers intValue]
                                      UIView:[self viewControllerForPresentStream].view];
}

- (void)stopStream {
}

- (void)timeOutTimer {
    if (self.isReading) {
        return;
    }
    [self stopTimer];
    self.isReading = YES;

    [self adapter:self
        didFailedToReceiveStreamWithError:[YUMIStreamError errorWithCode:YUMIStreamRequestTimeOut
                                                             description:@"auto stream time out"]];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSMutableArray *)modelArry {

    if (_modelArry == nil) {
        _modelArry = [[NSMutableArray alloc] init];
    }
    return _modelArry;
}

#pragma mark - YUMINativeAdRequest Delegate
- (void)nativeAdRequestFinishing:(YUMINativeAdRequest *)nativeAdRequest ResponseData:(NSArray *)dataArry {
    if (self.isReading) {
        return;
    }
    self.isReading = YES;
    [self stopTimer];

    self.nativeAd = nativeAdRequest;

    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArry.count; i++) {

        YUMINativeModel *nativeModel = dataArry[i];
        YUMIStreamModel *model = [[YUMIStreamModel alloc] init];
        model.html = nativeModel.adm;
        model.showType = showOfView;
        model.adapter = self;
        model.data = nativeModel;
        model.providerId = YuMIStreamNetworkAdNative;
        model.pid = [NSString stringWithFormat:@"%@_%d", [[YUMIStreamDevice shareDevice] getYUMIPid], i];
        [modelArray addObject:model];
    }

    [self adapter:self didReceiveStreamData:modelArray didReceiveStreamWithNumbers:(int)(modelArray.count)];
}

- (void)nativeAdRequestFailed:(YUMINativeAdRequest *)nativeAdRequest Error:(NSError *)error {
    if (self.isReading) {
        return;
    }
    self.isReading = YES;
    [self stopTimer];

    [self adapter:self
        didFailedToReceiveStreamWithError:[YUMIStreamError errorWithCode:YUMIStreamRequestNotAd
                                                             description:@"auto stream no ad"]];
}

- (void)showStream:(YUMIStreamModel *)streamModel view:(UIView *)view {

    [super showStream:streamModel view:view];

    //展示上报
    [_nativeAd sendDataStatisticsWithAppkey:self.streamProvider.key1
                        YuMiNativeAdRequest:self.nativeAd
                            YuMiNativeModel:streamModel.data
                                       type:YMNativeAdReportTypeShow
                                       view:nil];
}

- (void)clickStream:(YUMIStreamModel *)streamModel {
    //点击上报
    [_nativeAd sendDataStatisticsWithAppkey:self.streamProvider.key1
                        YuMiNativeAdRequest:self.nativeAd
                            YuMiNativeModel:streamModel.data
                                       type:YMNativeAdReportTypeClick
                                       view:nil];
}

@end
