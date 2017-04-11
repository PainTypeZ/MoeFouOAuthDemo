//
//  PTOAuthModel.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/11.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTOAuthModel.h"

@implementation PTOAuthModel
// 包含线程安全的单例声明
+ (instancetype)sharedOAuthModel
{
    static dispatch_once_t once;
    static id oauthModel;
    dispatch_once(&once, ^{
        oauthModel = [[self alloc] init];
        
    });
    return oauthModel;
}

// 重写变量属性的getter方法，每次调用oauthModel.xxxx自动生成新值
- (NSString *)oauthTimestamp {
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    _oauthTimestamp = [NSString stringWithFormat:@"%.f", timeInterval];
    return _oauthTimestamp;
}

- (NSString *)oauthNonce {
    _oauthNonce = [NSString stringWithFormat:@"%u", arc4random()];
    return _oauthNonce;
}
@end
