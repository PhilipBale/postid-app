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

@property (nonatomic, strong) NSArray<Notification>* results;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    
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
    
    
    //self.results = [[Notification objectsWhere:@"userId == %li", currentUser.userId] sortedResultsUsingProperty:@"notificationId" ascending:NO];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"minimo-bold" size:28]}];
    [self.navigationItem setTitle:@"postid"];
    
    if ([[currentUser imageUrl] length] > 0) {
        NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", currentUser.imageUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:url]
                                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        });
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notificationTableView reloadData];
    [self downloadAndRefreshNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2;
}

- (void)downloadAndRefreshNotifications
{
    NSNumber *minNotification = [[PostidManager sharedManager] loadMaxNotificationIdFromKeychain];
    if (!minNotification || true) { //Disable caching
        minNotification = [NSNumber numberWithInteger:0];
    }
    
    [PostidApi fetchNotificationsWithMinId:minNotification completion:^(BOOL success, NSArray<Notification> *notifications, NSNumber *maxId) {
        self.results = notifications;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.notificationTableView reloadData];
        });
    }];
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
