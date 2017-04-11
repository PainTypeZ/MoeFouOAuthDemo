//
//  PTOAuthTool.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/4/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTOAuthModel.h"
// 不返回值的block
typedef void (^requestCompleted)();
// 回调函数
typedef void (^callback)(NSDictionary *accessTokenDictionary);


@interface PTOAuthTool : NSObject
// 第一步 请求未授权的OAuthToken和Secret
+ (void)requestOAuthTokenWithURL:(NSString *)url andConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret completionHandler:(requestCompleted)requestCompleted;

// 第二步 拼接授权URL供浏览器访问，等待用户确认授权
+ (NSURL *)getAuthorizeURLWithURL:(NSString *)url;

// 第三步 获取到用户授权后的验证码，发送验证码请求accesstoken
+ (void)requestAccessOAuthTokenAndSecretWithURL:(NSString *)url andVerifier:(NSString *)verifier callback:(callback)callback;

@end
