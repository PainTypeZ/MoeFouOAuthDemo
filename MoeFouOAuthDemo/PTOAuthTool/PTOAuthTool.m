//
//  PTOAuthTool.m
//  OAuthTest
//
//  Created by 彭平军 on 2017/4/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTOAuthTool.h"
#import "NSString+PTCollection.h"

// OAuth步骤枚举
typedef NS_ENUM(NSUInteger, OAuthSteps) {
    OAuthStepsOne = 1,
    OAuthStepsTwo,
    OAuthStepsThree
};

@implementation PTOAuthTool

#pragma mark - public methods
// 第一步 请求未授权的OAuthToken和Secret
+ (void)requestOAuthTokenWithURL:(NSString *)url andConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret completionHandler:(requestCompleted)requestCompleted {
    
    // 获取PTOAuthModel单例对象并设置参数
    PTOAuthModel *oauthModel = [PTOAuthModel sharedOAuthModel];
    oauthModel.oauthURL = url;
    oauthModel.oauthConsumerKey = consumerKey;
    oauthModel.oauthConsumerSecret = consumerSecret;
    // 设置常量属性默认值
    oauthModel.oauthRequestMethod = @"GET";
    oauthModel.oauthVersion = @"1.0";
    oauthModel.oauthSignatureMethod = @"HMAC-SHA1";
    
    // 使用get请求
    NSURL *requestURL = [PTOAuthTool createOAuthCompletedGETURLWithSharedOAuthModelInOAuthSteps:OAuthStepsOne];// 传入步骤参数 第一步
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];

    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionary];
            NSArray *componentArray = [dataString componentsSeparatedByString:@"&"];
            for (NSString *subString in componentArray) {
                NSArray *subArray = [subString componentsSeparatedByString:@"="];
                NSString *keyString = [subArray firstObject];
                NSString *valueString = [subArray lastObject];
                [tokenDictionary setObject:valueString forKey:keyString];
            }
            if ([tokenDictionary[@"oauth_callback_confirmed"] isEqualToString:@"1"]) {
                NSLog(@"OAuth授权第一步成功，PTOAuthtool已获取到未授权的OAuthToken和OAuthTokenSecret");
            }else{
                NSLog(@"OAuth授权第一步失败，错误信息:%@", dataString);
                return;
            }
            // 将返回的token和secret赋值到单例model中
            oauthModel.oauthToken = tokenDictionary[@"oauth_token"];
            oauthModel.oauthTokenSecret = tokenDictionary[@"oauth_token_secret"];
            // 返回block
            requestCompleted();
        }else{
            NSLog(@"%@", [error description]);
        }
    }];
    // 开始任务
    [task resume];
}
// 第二步 拼接授权URL供浏览器访问，等待用户确认授权
+ (NSURL *)getAuthorizeURLWithURL:(NSString *)url {
    // 获取PTOAuthModel单例对象
    PTOAuthModel *oauthModel = [PTOAuthModel sharedOAuthModel];
    // 替换url
    oauthModel.oauthURL = url;
    // 用新的参数创建GETURL
    NSURL *authorizeURL = [PTOAuthTool createOAuthCompletedGETURLWithSharedOAuthModelInOAuthSteps:OAuthStepsTwo];// 传入步骤参数 第二步
    NSLog(@"OAuth授权第二步URL拼接成功，请等待用户在网页中确认授权");
    return authorizeURL;
}
// 第三步 获取到用户授权后的验证码，发送验证码请求accesstoken
+ (void)requestAccessOAuthTokenAndSecretWithURL:(NSString *)url andVerifier:(NSString *)verifier callback:(callback)callback {
    // 获取PTOAuthModel单例对象
    PTOAuthModel *oauthModel = [PTOAuthModel sharedOAuthModel];
    // 替换url,添加验证码
    oauthModel.oauthURL = url;
    oauthModel.verifier = verifier;
    // 用新的参数创建GETURL
    NSURL *requestURL = [PTOAuthTool createOAuthCompletedGETURLWithSharedOAuthModelInOAuthSteps:OAuthStepsThree];// 传入步骤参数 第三步
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableDictionary *accessTokenDictionary = [NSMutableDictionary dictionary];
            NSArray *componentArray = [dataString componentsSeparatedByString:@"&"];
            for (NSString *subString in componentArray) {
                NSArray *subArray = [subString componentsSeparatedByString:@"="];
                NSString *keyString = [subArray firstObject];
                NSString *valueString = [subArray lastObject];
                [accessTokenDictionary setObject:valueString forKey:keyString];
            }
            NSLog(@"OAuth授权第三步成功，请妥善保存token和secret");
            // 返回包含已授权token和secret的字典
            callback(accessTokenDictionary);
        }else{
            NSLog(@"%@", [error description]);
        }
    }];
    // 开始任务
    [task resume];
}

#pragma mark - private medthods
// 根据步骤数用PTOAuthModel单例对象生成OAuth加密签名,返回拼接好的URL
+ (NSURL *)createOAuthCompletedGETURLWithSharedOAuthModelInOAuthSteps:(OAuthSteps)oauthStep  {
    // 获取PTOAuthModel单例对象
    PTOAuthModel *oauthModel = [PTOAuthModel sharedOAuthModel];
    
    // 创建参数字典
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    [paramsDictionary setObject:oauthModel.oauthConsumerKey forKey:@"oauth_consumer_key"];
    [paramsDictionary setObject:oauthModel.oauthTimestamp forKey:@"oauth_timestamp"];
    [paramsDictionary setObject:oauthModel.oauthNonce forKey:@"oauth_nonce"];
    [paramsDictionary setObject:oauthModel.oauthVersion forKey:@"oauth_version"];
    [paramsDictionary setObject:oauthModel.oauthSignatureMethod forKey:@"oauth_signature_method"];
    // 判断是否包含oauth_token(只有第一步不包含oauth_oken)
    if (oauthStep != OAuthStepsOne) {
        [paramsDictionary setObject:oauthModel.oauthToken forKey:@"oauth_token"];
    }
    // 判断是否包含verifier(只有第三步需要verifier)
    if (oauthStep == OAuthStepsThree) {
        [paramsDictionary setObject:oauthModel.verifier forKey:@"verifier"];
    }
    // 得到参数字符串(升序)
    NSString *paramsString = [NSString ascendingOrderGETRequesetParamsDictionary:paramsDictionary];
    
    // 得到baseString
    NSString *encodeURL = [NSString urlEncodeString:oauthModel.oauthURL];// 自定义分类实现
    NSString *encodeParams = [NSString urlEncodeString:paramsString];// 自定义分类实现
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", oauthModel.oauthRequestMethod, encodeURL, encodeParams];
    // 得到encodeSignature
    NSString *secret = @"";
    // 判断是否包含oauth_token_secret(除第三步外，都不包含oauth_token_secret)
    if (oauthStep == OAuthStepsThree) {
        secret = [NSString stringWithFormat:@"%@&%@", oauthModel.oauthConsumerSecret, oauthModel.oauthTokenSecret];
    } else {
        secret = [NSString stringWithFormat:@"%@&", oauthModel.oauthConsumerSecret];
    }
    // OAuth签名Base64_HMA-CHA1加密
    NSString *signature = [NSString base64_HMAC_SHA1:secret string:baseString];// 自定义分类实现
    // OAuth签名URL编码
    NSString *encodeSignature = [NSString urlEncodeString:signature];// 自定义分类实现

    NSString *path = [NSString stringWithFormat:@"%@?%@&oauth_signature=%@", oauthModel.oauthURL, paramsString, encodeSignature];
    NSURL *completedGETURL = [NSURL URLWithString:path];
    return completedGETURL;
}

@end
