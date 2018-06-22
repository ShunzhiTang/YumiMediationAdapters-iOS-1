//
//  YumiMediationVideoAdapterCentrixlink.m
//  YumiMediationAdapters
//
//  Created by ShunZhi Tang on 2017/9/22.
//

#import "YumiMediationVideoAdapterCentrixlink.h"
#import <Centrixlink/Centrixlink.h>

@interface YumiMediationVideoAdapterCentrixlink () <CentrixLinkADDelegate>

@property (nonatomic) CentrixlinkAD *video;

@end

@implementation YumiMediationVideoAdapterCentrixlink
+ (void)load {
    [[YumiMediationAdapterRegistry registry] registerVideoAdapter:self
                                                      forProvider:kYumiMediationAdapterIDCentrixlink
                                                      requestType:YumiMediationSDKAdRequest];
}

+ (id<YumiMediationVideoAdapter>)sharedInstance {
    static id<YumiMediationVideoAdapter> sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark : YumiMediationVideoAdapter
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                 delegate:(id<YumiMediationVideoAdapterDelegate>)delegate {
    self = [super init];
    
    self.provider = provider;
    self.delegate = delegate;

    self.video = [CentrixlinkAD sharedInstance];
    [self.video setDebugEnable:NO];
    [self.video setPlayAdOrientation:UIInterfaceOrientationMaskAll];
    
    return self;
}

- (void)requestAd {

    NSError *error;

    [self.video startWithAppID:self.provider.data.key1 AppSecretKey:self.provider.data.key2 error:&error];
    if (error) {
        [self.delegate adapter:self videoAd:self.video didFailToLoad:[error localizedDescription]];
    }

    [self.video setDelegate:self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSError *error = nil;
    [self.video playAD:rootViewController options:@{ CentrixlinkPlayAdOptionKeyIECAutoClose : @(YES) } error:&error];

    if (error) {

        [self.delegate adapter:self videoAd:self.video didFailToLoad:[error localizedDescription]];
    }
}

- (BOOL)isReady {

    return [[CentrixlinkAD sharedInstance] hasPreloadAD];
}

#pragma mark--CentrixlinkDelegate

- (void)centrixLinkHasPreloadAD:(BOOL)hasPreload {
    if (hasPreload) {
        [self.delegate adapter:self didReceiveVideoAd:self.video];
    } else {
        [self.delegate adapter:self videoAd:self.video didFailToLoad:@"centrixLink not preload"];
    }
}

- (void)centrixLinkVideoADWillShow:(NSDictionary *)ADInfo {
    [self.delegate adapter:self didStartPlayingVideoAd:self.video];
}

- (void)centrixLinkVideoADDidShow:(NSDictionary *)ADInfo {
    [self.delegate adapter:self didOpenVideoAd:self.video];
}

- (void)centrixLinkVideoADClose:(NSDictionary *)ADInfo {
    NSNumber *isplayFinished = [ADInfo objectForKey:ADInfoKEYADPlayStatus];
    if ([isplayFinished boolValue]) {
        [self.delegate adapter:self videoAd:self.video didReward:nil];
    }
    [self.delegate adapter:self didCloseVideoAd:self.video];
}

- (void)centrixLinkVideoADShowFail:(NSError *)error {

    [self.delegate adapter:self videoAd:self.video didFailToLoad:[error localizedDescription]];
}

@end
