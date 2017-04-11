//
//  ViewController.m
//  MoeFouOAuthDemo
//
//  Created by 彭平军 on 2017/4/11.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *OAuthButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"oauth_token"]) {
        [self.OAuthButton setTitle:@"已授权" forState:UIControlStateNormal];
        self.OAuthButton.userInteractionEnabled = NO;
    }
}

- (IBAction)OAuthAciton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"pushOAuthWebViewController" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
