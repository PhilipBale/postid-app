//
//  AppEntryViewController.m
//  Postid
//
//  Created by Philip Bale on 8/15/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AppEntryViewController.h"
#import "PostidManager.h"
#import "PostidApi.h"

@interface AppEntryViewController ()

@end

@implementation AppEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *token = [[PostidManager sharedManager] loadTokenFromKeychain];
    if (token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self attemptAutoLoginWithToken:token];
        });
    }
    
    self.loginButton.layer.cornerRadius = 10;
    self.loginButton.layer.borderColor = [UIColor lightTextColor].CGColor;
    self.loginButton.layer.borderWidth = 1;
    self.signupButton.layer.cornerRadius = 10;
    self.signupButton.layer.borderColor = [UIColor lightTextColor].CGColor;
    self.signupButton.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)attemptAutoLoginWithToken:(NSString *)token {
    [self.autoLoginIndicator startAnimating];
    [self setButtonsEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [PostidApi loginWithToken:token completion:^(BOOL success, User *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.autoLoginIndicator stopAnimating];
            [self setButtonsEnabled:YES];
        });
        
        if (success)
        {
            [[PostidManager sharedManager] setCurrentUser:user];
            [self performSegueWithIdentifier:@"login" sender:self];
        }
    }];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.loginButton.enabled = enabled;
    self.signupButton.enabled = enabled;
}
@end
