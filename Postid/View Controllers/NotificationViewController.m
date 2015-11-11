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
#import "Notification.h"
#import "PostidApi.h"
#import "NotificationCell.h"

@interface NotificationViewController ()

@property (nonatomic, strong) RLMResults* results;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.height + 10;
    self.userImageView.clipsToBounds = YES;
    
    self.friendButton.layer.cornerRadius = 8;
    self.friendButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.friendButton.layer.borderWidth = 1.5;
    
    
    User *currentUser = [[PostidManager sharedManager] currentUser];
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.username];
    self.userFullNameLabel.text = [currentUser name];
    NSInteger friendCount = currentUser.friends.count;
    [self.friendButton setTitle:[NSString stringWithFormat:@"%li friends", (long)friendCount] forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
    
    self.results = [[Notification objectsWhere:@"userId == %li", currentUser.userId] sortedResultsUsingProperty:@"notificationId" ascending:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notificationTableView reloadData];
    [self downloadAndRefreshNotifications];
}

- (void)downloadAndRefreshNotifications
{
    NSNumber *minNotification = [[PostidManager sharedManager] loadMaxNotificationIdFromKeychain];
    if (!minNotification) {
        minNotification = [NSNumber numberWithInteger:0];
    }
    
    [PostidApi fetchNotificationsWithMinId:minNotification completion:^(BOOL success, NSArray *notifications, NSNumber *maxId) {
        if (success)
        {
            [[PostidManager sharedManager] cacheNotifications:notifications];
            
            //TODO set new max post id, will get intensive as app gets popular
        }
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self.notificationTableView reloadData];
        });
    }];
}

- (IBAction)friendButtonPressed:(id)sender {
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[PostidManager sharedManager] logout];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NotificationCell class]) forIndexPath:indexPath];
    
    Notification* notification = [self.results objectAtIndex:indexPath.row];
    cell.notification = notification;
    cell.parent = self;
    
    return cell;
}


@end
