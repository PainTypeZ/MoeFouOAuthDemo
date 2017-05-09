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
    OAuthStepsThree,
    OAuthStepsGetResource
};

@implementation PTOAuthTool

#pragma mark - public methods
// 第一步 请求未授权的OAuthToken和Secret
+ (void)requestOAuthTokenWithURL:(NSString *)url completionHandler:(requestCompleted)requestCompleted {
    
    // 创建PTOAuthModel对象
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    // 添加url
    oauthModel.oauthURL = url;  
    
    // 创建含OAuth加密签名的完整GET请求URL
    NSURL *requestURL = [PTOAuthTool createOAuthCompletedGETURLWithPTOAuthModel:oauthModel inOAuthSteps:OAuthStepsOne];// 传入步骤参数 第一步
    
    // 使用get请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];

    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([dataString containsString:@"oauth_token="]) {
                NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionary];
                NSArray *componentArray = [dataString componentsSeparatedByString:@"&"];
                for (NSString *subString in componentArray) {
                    NSArray *subArray = [subString componentsSeparatedByString:@"="];
                    NSString *keyString = [subArray firstObject];
                    NSString *valueString = [subArray lastObject];
                    [tokenDictionary setObject:valueString forKey:keyString];
                }
                NSString *oauthToken = tokenDictionary[@"oauth_token"];
                NSString *oauthTokenSecret = tokenDictionary[@"oauth_token_secret"];
                NSLog(@"oauthToken:%@\noauthTokenSecret:%@", oauthToken, oauthTokenSecret);
                // 将返回的未授权的token和secret写入偏好设置
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:oauthToken forKey:@"oauth_token"] ;
                [userDefaults setObject:oauthTokenSecret forKey:@"oauth_token_secret"];
                [userDefaults synchronize];
                
                NSLog(@"OAuth授权第一步成功，获取到未授权的oauth_token和oauth_token_secret已写入偏好设置");
                
            }else{
                NSLog(@"OAuth授权第一步失败，错误信息:%@", dataString);
                return;
            }
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
    // 创建PTOAuthModel对象
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    // 添加url
    oauthModel.oauthURL = url;
    // 用新的参数创建含OAuth加密签名的完整GET请求URL
    NSURL *authorizeURL = [PTOAuthTool createOAuthCompletedGETURLWithPTOAuthModel:oauthModel inOAuthSteps:OAuthStepsTwo];// 传入步骤参数 第二步
    NSLog(@"OAuth授权第二步URL拼接成功，请等待用户在网页中确认授权");
    return authorizeURL;
}
// 第三步 获取到用户授权后的验证码，发送验证码请求accesstoken
+ (void)requestAccessOAuthTokenAndSecretWithURL:(NSString *)url andVerifier:(NSString *)verifier completionHandler:(requestCompleted)requestCompleted {
    // 创建PTOAuthModel对象
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    // 添加url,添加验证码
    oauthModel.oauthURL = url;
    oauthModel.oauthVerifier = verifier;
    // 用新的参数创建含OAuth加密签名的完整GET请求URL
    NSURL *requestURL = [PTOAuthTool createOAuthCompletedGETURLWithPTOAuthModel:oauthModel inOAuthSteps:OAuthStepsThree];// 传入步骤参数 第三步
    
    // 使用get请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([dataString containsString:@"oauth_token="]) {
                NSMutableDictionary *accessTokenDictionary = [NSMutableDictionary dictionary];
                NSArray *componentArray = [dataString componentsSeparatedByString:@"&"];
                for (NSString *subString in componentArray) {
                    NSArray *subArray = [subString componentsSeparatedByString:@"="];
                    NSString *keyString = [subArray firstObject];
                    NSString *valueString = [subArray lastObject];
                    [accessTokenDictionary setObject:valueString forKey:keyString];
                }
                NSString *accessOAuthToken = accessTokenDictionary[@"oauth_token"];
                NSString *accessOAuthTokenSecret = accessTokenDictionary[@"oauth_token_secret"];
                NSLog(@"accessOAuthToken:%@\naccessOAuthTokenSecret:%@", accessOAuthToken, accessOAuthTokenSecret);
                // 将返回的已授权的token和secret写入偏好设置
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:accessOAuthToken forKey:@"oauth_token"];
                [userDefaults setObject:accessOAuthTokenSecret forKey:@"oauth_token_secret"];
                [userDefaults setBool:YES forKey:@"isLogin"];
                [userDefaults synchronize];
                
                NSLog(@"OAuth授权第三步成功，已授权的oauth_token和oauth_token_secret已写入偏好设置，key:oauth_token, oauth_token_secret");
            }else{
                NSLog(@"OAuth授权第三步失败，错误信息:%@", dataString);
                return;
            }
            // 返回block
            requestCompleted();
        }else{
            NSLog(@"%@", [error description]);
        }
    }];
    // 开始任务
    [task resume];
}

// 获取OAuthResource请求的完整URL
+ (NSURL *)getCompletedOAuthResourceRequestURLWithURLString:(NSString *)url andParams:(NSDictionary *)params {
    // 创建PTOAuthModel对象
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    // 添加url和params
    oauthModel.oauthURL = url;
    oauthModel.params = params;
    
    // 用新的参数创建GETURL
    NSURL *completedOAuthResourceRequestURL = [PTOAuthTool createOAuthCompletedGETURLWithPTOAuthModel:oauthModel inOAuthSteps:OAuthStepsGetResource];
    return completedOAuthResourceRequestURL;
}

#pragma mark - private medthods
// 根据步骤数用传入PTOAuthModel实例生成OAuth加密签名,返回拼接好的URL
+ (NSURL *)createOAuthCompletedGETURLWithPTOAuthModel:(PTOAuthModel *)oauthModel inOAuthSteps:(OAuthSteps)oauthStep {
    
    // 创建参数字典,判断是否为通用方法且参数不是nil
    NSMutableDictionary *paramsDictionary = (oauthStep == OAuthStepsGetResource) && oauthModel.params ? [NSMutableDictionary dictionaryWithDictionary:oauthModel.params] : [NSMutableDictionary dictionary];
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
        [paramsDictionary setObject:oauthModel.oauthVerifier forKey:@"verifier"];
    }
    // 得到参数字符串(升序)
    NSString *paramsString = [NSString ascendingOrderGETRequesetParamsDictionary:paramsDictionary];
    
    // 得到baseString
    NSString *encodeURL = [NSString urlEncodeString:oauthModel.oauthURL];// 自定义分类实现
    NSString *encodeParams = [NSString urlEncodeString:paramsString];// 自定义分类实现
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", oauthModel.oauthRequestMethod, encodeURL, encodeParams];
    // 得到encodeSignature
    NSString *secret = @"";
    // 判断是否包含oauth_token_secret(第三步和通用方法，都包含oauth_token_secret)
    if (oauthStep >= OAuthStepsThree) {
        secret = [NSString stringWithFormat:@"%@&%@", oauthModel.oauthConsumerSecret, oauthModel.oauthTokenSecret];
    } else {
        secret = [NSString stringWithFormat:@"%@&", oauthModel.oauthConsumerSecret];
    }
    // OAuth签名Base64_HMAC-SHA1加密
    NSString *signature = [NSString base64_HMAC_SHA1:secret string:baseString];// 自定义分类实现
    // OAuth签名URL编码
    NSString *encodeSignature = [NSString urlEncodeString:signature];// 自定义分类实现

    NSString *path = [NSString stringWithFormat:@"%@?%@&oauth_signature=%@", oauthModel.oauthURL, paramsString, encodeSignature];
    NSURL *completedGETURL = [NSURL URLWithString:path];
    return completedGETURL;
}
@end
