//
//  PTOAuthModel.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/11.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTOAuthModel : NSObject
// 请求地址，consumerKey和secret
@property (copy, nonatomic) NSString *oauthURL;
@property (copy, nonatomic) NSString *oauthConsumerKey;
@property (copy, nonatomic) NSString *oauthConsumerSecret;
// 萌否的OAuth验证码
@property (copy, nonatomic) NSString *verifier;
// 未授权的token和secret
@property (copy, nonatomic) NSString *oauthToken;
@property (copy, nonatomic) NSString *oauthTokenSecret;
// 时间戳和随机数，自动生成
@property (copy, nonatomic) NSString *oauthTimestamp;
@property (copy, nonatomic) NSString *oauthNonce;
// 常量，OAuth请求方式，OAuth版本，签名加密方法
@property (copy, nonatomic) NSString *oauthRequestMethod;
@property (copy, nonatomic) NSString *oauthVersion;
@property (copy, nonatomic) NSString *oauthSignatureMethod;
// 单例构造方法
+ (instancetype)sharedOAuthModel;

@end
