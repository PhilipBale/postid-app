//
//  LoginViewController.m
//  Postid
//
//  Created by Philip Bale on 8/16/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "PostidManager.h"
#import "PostidApi.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.layer.cornerRadius = 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.loginActivityIndicatorView startAnimating];
    [self.loginButton setEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    NSString *empty = @"nil";
    [PostidApi loginOrRegisterWithEmail:empty password:self.passwordTextField.text firstName:empty lastName:empty username:self.usernameTextField.text isLogin:YES completion:^(BOOL success, User *user, NSDictionary *friendData){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loginActivityIndicatorView stopAnimating];
            [self.loginButton setEnabled:YES];
        });
        
        if (success)
        {
            [[PostidManager sharedManager] setCurrentUser:user];
            [[PostidManager sharedManager] cacheFriendsData:friendData];
            [self performSegueWithIdentifier:@"login" sender:self];
        }
    }];
}

@end
