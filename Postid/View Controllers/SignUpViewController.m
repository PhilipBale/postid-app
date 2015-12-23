//
//  SignUpViewController.m
//  Postid
//
//  Created by Philip Bale on 8/16/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "SignUpViewController.h"
#import "GeneralUtilities.h"
#import "User.h"
#import "PostidApi.h"
#import "PostidManager.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signupButton.layer.cornerRadius = 10;
    self.photoButton.layer.cornerRadius = 5;
    self.photoButton.layer.borderWidth = 1;
    self.photoButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.photoButton.clipsToBounds = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPhotoButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)imagePickerController:(UIImagePickerController *)thePicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (thePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    [self.photoButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.photoButton setTitle:@"" forState:UIControlStateNormal];
    
    NSLog(@"Image found");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpButtonPressed:(id)sender
{
    if ([self validateFields])
    {
        [self.signupActivityIndicatorView startAnimating];
        [self.signupButton setEnabled:NO];
        
        
        __weak typeof(self) weakSelf = self;
        
        [PostidApi loginOrRegisterWithEmail:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text username:self.usernameTextField.text isLogin:NO completion:^(BOOL success, User *user, NSDictionary *friendData) {
            
            if (success) {
                [[PostidManager sharedManager] uploadProfilePhoto:UIImageJPEGRepresentation([self.photoButton backgroundImageForState:UIControlStateNormal], 0.8) completion:^(BOOL success, NSString *imageName) {
                    
                    
                    [[PostidManager sharedManager] setCurrentUser:user]; // Needed to set HTTP headers

                    if (success && [imageName length] > 6) {
                        user.imageUrl = imageName;
                        [PostidApi updateImageUrl:imageName forToken:user.token completion:^(BOOL success, User *newUser) {
                            if (success) {
                                NSLog(@"Successfully set user image for new signup");
                            }
                        }];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.signupActivityIndicatorView stopAnimating];
                        [self.signupButton setEnabled:YES];
                        
                        [[PostidManager sharedManager] setCurrentUser:user];
                        [[PostidManager sharedManager] cacheFriendsData:friendData];
                        
                        [self performSegueWithIdentifier:@"login" sender:self];
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.signupActivityIndicatorView stopAnimating];
                    [weakSelf.signupButton setEnabled:YES];
                });
            }
        }];
    }
}

- (BOOL)validateFields
{
    if (self.firstNameTextField.text.length < 2)
    {
        [GeneralUtilities makeAlertWithTitle:@"Invalid first name" message:@"Please enter a valid first name!" viewController:self];
        return NO;
    }
    else if (self.lastNameTextField.text.length < 2)
    {
        [GeneralUtilities makeAlertWithTitle:@"Invalid last name" message:@"Please enter a valid last name!" viewController:self];
        return NO;
    }
    else if (self.usernameTextField.text.length < 2)
    {
        [GeneralUtilities makeAlertWithTitle:@"Invalid username" message:@"Please enter a valid username!" viewController:self];
        return NO;
    }
    else if (![self validateEmail:self.emailTextField.text])
    {
        [GeneralUtilities makeAlertWithTitle:@"Invalid email" message:@"Please enter a valid .edu email address" viewController:self];
        return NO;
    }
    else if (self.passwordTextField.text.length < 6)
    {
        [GeneralUtilities makeAlertWithTitle:@"Password too short" message:@"Please make password at least 6 characters long" viewController:self];
        return NO;
    }
    else if ([self.photoButton backgroundImageForState:UIControlStateNormal] == nil)
    {
        
        [GeneralUtilities makeAlertWithTitle:@"Profile image not set" message:@"Please choose a profile image" viewController:self];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.edu";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

@end
