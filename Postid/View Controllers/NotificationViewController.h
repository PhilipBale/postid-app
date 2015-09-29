//
//  NotificationViewController.h
//  Postid
//
//  Created by Philip Bale on 9/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface NotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userFullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;

@end
