//
//  YumiMediationFacebookHeaderBiddingAdapterBanner.h
//  Pods-YumiMediationSDK-iOS_Example
//
//  Created by 王泽永 on 2018/8/28.
//

#import <Foundation/Foundation.h>

@interface YumiMediationFacebookHeaderBiddingAdapterBanner : NSObject

@property (nonatomic, getter=fetchFacebookBidderToken) NSString *bidderToken;
@property (nonatomic) NSString *bidPayload;
@end
