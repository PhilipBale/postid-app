//
//  SearchViewController.m
//  Postid
//
//  Created by Philip Bale on 8/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "SearchViewController.h"
#import <DigitsKit/DigitsKit.h>
#import "PostidManager.h"
#import "User.h"
#import "PostidApi.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[PostidManager sharedManager] currentUser].phoneNumber.length == 0) {
        [DigitsKit logOut];
        DGTAuthenticateButton *authenticateButton = [DGTAuthenticateButton buttonWithAuthenticationCompletion:^(DGTSession *session, NSError *error) {
            User *currentUser = [[PostidManager sharedManager] currentUser];
            if ([session.phoneNumber length])
            {
                [currentUser setPhoneNumber:session.phoneNumber];
                [PostidApi updatePhoneNumber:session.phoneNumber forToken:currentUser.token completion:^(BOOL success, User *user) {
                    if (success)
                    {
                      [[PostidManager sharedManager] setCurrentUser:user];
                        [authenticateButton setHidden:YES];
                    }
                }];
            }
        }];
         
        authenticateButton.layer.borderColor = PRIMARY_COLOR.CGColor;
        authenticateButton.layer.borderWidth = 2;
        authenticateButton.layer.cornerRadius = 5;
        authenticateButton.center = self.view.center;
        [authenticateButton setTitleColor:PRIMARY_COLOR forState:UIControlStateNormal];
        [authenticateButton setBackgroundColor:[UIColor clearColor]];
        [authenticateButton setTitle:@"Authenticate Phone to Search" forState:UIControlStateNormal];
        [self.view addSubview:authenticateButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
