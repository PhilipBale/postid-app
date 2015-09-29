//
//  NotificationViewController.m
//  Postid
//
//  Created by Philip Bale on 9/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "NotificationViewController.h"
#import "User.h"
#import "PostidManager.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.height + 10;
    self.userImageView.clipsToBounds = YES;
    
    self.friendButton.layer.cornerRadius = 8;
    self.friendButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.friendButton.layer.borderWidth = 1.5;
    
    
    User *currentUser = [[PostidManager sharedManager] currentUser];
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.username];
    self.userFullNameLabel.text = [currentUser name];
    NSInteger friendCount = currentUser.friends.count;
    [self.friendButton setTitle:[NSString stringWithFormat:@"%li friends", friendCount] forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)friendButtonPressed:(id)sender {
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[PostidManager sharedManager] logout];
}


@end
