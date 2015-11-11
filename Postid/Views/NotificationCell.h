//
//  NotificationCell.h
//  Postid
//
//  Created by Philip Bale on 11/11/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationViewController.h"
#import "Notification.h"

@interface NotificationCell : UITableViewCell

@property (nonatomic, strong) NotificationViewController *parent; //hack
@property (nonatomic, strong) Notification *notification;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@end
