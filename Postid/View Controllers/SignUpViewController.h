//
//  SignUpViewController.h
//  Postid
//
//  Created by Philip Bale on 8/16/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppEntryTextField.h"

@interface SignUpViewController : UIViewController<UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (weak, nonatomic) IBOutlet AppEntryTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet AppEntryTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet AppEntryTextField *emailTextField;
@property (weak, nonatomic) IBOutlet AppEntryTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet AppEntryTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signupActivityIndicatorView;

@end
