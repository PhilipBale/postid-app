//
//  PostSelectorViewController.m
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PostSelectorViewController.h"
#import "User.h"
#import "PostidManager.h"
#import "AddPostCell.h"

@interface PostSelectorViewController ()

@property (strong, nonatomic) NSMutableArray* results;

@end

@implementation PostSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    NSMutableArray *allUsers = [[NSMutableArray alloc] init];
    
    for (User *user in currentUser.friends)
    {
        [allUsers addObject:user];
    }
    
    allUsers = [[allUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        User *first = obj1;
        User *second = obj2;
        
        if ([[first name] isEqualToString:[second name]])
        {
            return NSOrderedSame;
        } else {
            return [[first name] compare:[second name]];
        }
    }] mutableCopy];
    
    self.results = allUsers;
    
    [self.tableView reloadData];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddPostCell" forIndexPath:indexPath];
    User *user = [self.results objectAtIndex:indexPath.row];
    
    cell.userFullNameLabel.text = [user name];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (IBAction)postButtonSelected:(id)sender {
    NSArray *indexes = [self.tableView indexPathsForSelectedRows];
    if ([indexes count] == 0)
        return;
    [self.activityIndicator startAnimating];
    
    NSMutableArray *usersToPostFor = [[NSMutableArray alloc] init];
    for (NSIndexPath *path in indexes) {
        User* user = [self.results objectAtIndex:path.row];
        [usersToPostFor addObject:[NSNumber numberWithInteger:user.userId]];
    }
    
    [[PostidManager sharedManager] makePostForUsers:usersToPostFor withImageData:[[PostidManager sharedManager] lastImageData] completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if (success)
            {
                [self performSegueWithIdentifier:@"mainTabBar" sender:self];
            }
        });
    }];
}


@end
