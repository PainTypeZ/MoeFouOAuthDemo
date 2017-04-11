//
//  OAuthViewController.m
//  MoeFouOAuthSample
//
//  Created by 彭平军 on 2017/4/11.
//  Copyright © 2017年 彭平军. All rights reserved.
//

// 填上你的moefou应用信息
#define kConsumerKey @"consumer_key"
#define kConsumerSecret @"consumer_secret"

#define kRequestTokenURL @"http://api.moefou.org/oauth/request_token"
#define kRequestAuthorizeURL @"http://api.moefou.org/oauth/authorize"
#define kRequestAccessTokenURL @"http://api.moefou.org/oauth/access_token"

#import "PTOAuthTool.h"
#import "OAuthViewController.h"

@interface OAuthViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *authorizeWebView;

@end

@implementation OAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self oauthStepsBegin];
}

- (void)oauthStepsBegin {
    // OAuth授权第一步
    [PTOAuthTool requestOAuthTokenWithURL:kRequestTokenURL andConsumerKey:kConsumerKey andConsumerSecret:kConsumerSecret completionHandler:^{
        // OAuth授权第二步
        NSURL *requestURL = [PTOAuthTool getAuthorizeURLWithURL:kRequestAuthorizeURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [self.authorizeWebView loadRequest:request];
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *path = [request.URL description];
    NSLog(@"%@", path);
    // 根据url包含的字符串获取验证码
    if ([path containsString:@"verifier="]) {
        NSString *subString = [[path componentsSeparatedByString:@"&"] firstObject];
        NSString *verifier = [[subString componentsSeparatedByString:@"="] lastObject];
        // OAuth授权第三步
        [PTOAuthTool requestAccessOAuthTokenAndSecretWithURL:kRequestAccessTokenURL andVerifier:verifier callback:^(NSDictionary *accessTokenDictionary) {
            //得到返回的accessToken和Secret，可以自定义保存方式和位置, demo选择保存到偏好设置
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:accessTokenDictionary[@"oauth_token"] forKey:@"oauth_token"];
            [userDefaults setObject:accessTokenDictionary[@"oauth_token_secret"] forKey:@"oauth_token_secret"];
            [userDefaults synchronize];
            NSLog(@"%@", accessTokenDictionary);
            // 此处可以添加提示信息等效果
            // 跳转回主界面
            [self.navigationController popViewControllerAnimated:YES];

        }];
        return NO;
    }
    return YES;
}

@end
