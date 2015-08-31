//
//  ProfileViewController.m
//  Postid
//
//  Created by Philip Bale on 8/24/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostidManager.h"

@implementation ProfileViewController

-(void)viewDidLoad
{
    
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[PostidManager sharedManager] logout];
}

@end
