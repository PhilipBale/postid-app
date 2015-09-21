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
    [self performSegueWithIdentifier:@"mainTabBar" sender:self];
}


@end
