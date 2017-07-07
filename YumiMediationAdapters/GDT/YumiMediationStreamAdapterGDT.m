//
//  YumiMediationStreamAdapterGDT.m
//  Pods
//
//  Created by 魏晓磊 on 2017/7/7.
//
//

#import "YumiMediationStreamAdapterGDT.h"
#import "GDTNativeAd.h"
#import "YUMIStreamModel.h"

@interface YumiMediationStreamAdapterGDT() <GDTNativeAdDelegate>

@property (nonatomic) GDTNativeAd *nativeAd;
@property (nonatomic) NSArray *data;
@property (nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL isReading;

@end

@implementation YumiMediationStreamAdapterGDT

+(NSString *)StreamRegister {
    return YuMIStreamNetworkAdGDT;
}

+ (void)load {
    [[YUMIStreamSDKAdNetworkRegister sharedRegister] registerStreamClass:self];
}

- (void)getStream:(NSString *)numbers {
    
    [self startStream];
    
    self.isReading=NO;
    
    NSTimeInterval interval = [self.streamProvider.outTime doubleValue];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(timeOutTimer)
                                                userInfo:nil
                                                 repeats:NO];

    
    self.nativeAd = [[GDTNativeAd alloc] initWithAppkey:self.streamProvider.key1 placementId:self.streamProvider.key2];
    self.nativeAd.controller = [self viewControllerForPresentStream];
    self.nativeAd.delegate = self;
    [self.nativeAd loadAd:[numbers intValue]];
    
}

- (void)stopStream {
    
}

-(void)timeOutTimer{
    if (self.isReading) {
        return;
    }
    [self stopTimer];
    self.isReading=YES;
    
    [self adapter:self didFailedToReceiveStreamWithError:[NSError errorWithDomain:@"GDT stream time out" code:8 userInfo:nil]];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - GDTNativeAdDelegate
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    
    if (self.isReading) {
        return;
    }
    [self stopTimer];
    self.isReading=YES;
    
    if(!nativeAdDataArray || ![nativeAdDataArray objectAtIndex:0]){
        [self adapter:self didFailedToReceiveStreamWithError:[NSError errorWithDomain:@"GDT stream no ad" code:8 userInfo:nil]];
        return;
    }
    
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for (int i=0; i<nativeAdDataArray.count; i++) {
        
        GDTNativeAdData *data = nativeAdDataArray[i];
        
        YUMIStreamModel *model = [[YUMIStreamModel alloc] init];
        model.title = data.properties[GDTNativeAdDataKeyTitle];
        model.desc = data.properties[GDTNativeAdDataKeyDesc];
        model.iconUrl = data.properties[GDTNativeAdDataKeyIconUrl];
        model.imgUrl = data.properties[GDTNativeAdDataKeyImgUrl];
        model.appRating = data.properties[GDTNativeAdDataKeyAppRating];
        model.appPrice = data.properties[GDTNativeAdDataKeyAppPrice];
        model.showType = showOfData;
        model.adapter = self;
        model.data = data;
        model.providerId = YuMIStreamNetworkAdGDT;
        model.pid = [NSString stringWithFormat:@"%@_%d",[[YUMIStreamDevice shareDevice] getYUMIPid],i];
        [modelArray addObject:model];
    }
    
    [self adapter:self didReceiveStreamData:modelArray didReceiveStreamWithNumbers:(int)(modelArray.count)];
    
}

-(void)nativeAdFailToLoad:(NSError *)error{
    if (self.isReading) {
        return;
    }
    self.isReading=YES;
    [self stopTimer];
    
    [self adapter:self didFailedToReceiveStreamWithError:[NSError errorWithDomain:@"GDT stream no ad" code:8 userInfo:nil]];
}


- (void)showStream:(YUMIStreamModel *)streamModel view:(UIView *)view {
    [super showStream:streamModel view:view];
    
    [_nativeAd attachAd:streamModel.data toView:view];
}

- (void)clickStream:(YUMIStreamModel *)streamModel {
    [super clickStream:streamModel];
    
    
    [_nativeAd clickAd:streamModel.data];
}

@end
