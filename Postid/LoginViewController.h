//
//  LoginViewController.h
//  Postid
//
//  Created by Philip Bale on 8/16/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppEntryTextField.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet AppEntryTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet AppEntryTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicatorView;

@end
