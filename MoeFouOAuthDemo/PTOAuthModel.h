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
@property (copy, nonatomic, readonly) NSString *oauthConsumerKey;
@property (copy, nonatomic, readonly) NSString *oauthConsumerSecret;
// 萌否的OAuth验证码
@property (copy, nonatomic) NSString *oauthVerifier;
// OAuth的token和secret(包括未授权和已授权)
@property (copy, nonatomic, readonly) NSString *oauthToken;
@property (copy, nonatomic, readonly) NSString *oauthTokenSecret;
// 时间戳和随机数，自动生成, 请勿进行赋值操作
@property (copy, nonatomic) NSString *oauthTimestamp;
@property (copy, nonatomic) NSString *oauthNonce;
// 常量，OAuth请求方式，OAuth版本，签名加密方法
@property (copy, nonatomic, readonly) NSString *oauthRequestMethod;
@property (copy, nonatomic, readonly) NSString *oauthVersion;
@property (copy, nonatomic, readonly) NSString *oauthSignatureMethod;

// 通用OAuthGET请求的参数字典
@property (strong, nonatomic) NSDictionary *params;
// 单例构造方法
//+ (instancetype)sharedOAuthModel;

@end
