//
//  ProfileFeedViewController.m
//  Postid
//
//  Created by Philip Bale on 12/17/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "ProfileFeedViewController.h"
#import "FeedCell.h"
#import "PostidApi.h"
#import "PostidManager.h"
#import <Realm/RLMRealm.h>
#import "UserId.h"

@interface ProfileFeedViewController ()
{
    CGFloat cellHeight;
}

@property (nonatomic, strong) NSMutableArray* results;

@end

@implementation ProfileFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    cellHeight = [[UIScreen mainScreen] bounds].size.height / 640 * 275;
    
    
    NSInteger userToDisplayId = [[PostidManager sharedManager] currentUser].userId;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"approved == YES"];
    RLMResults *rlmResults = [[Post objectsWithPredicate:searchPredicate] sortedResultsUsingProperty:@"postId" ascending:NO];
    self.results = [[NSMutableArray alloc] init];
    for (Post* post in rlmResults)
    {
        BOOL include = NO;
        for (UserId *userId in post.postidForIds)
        {
            if (userId.userId == userToDisplayId) {
                include = YES;
            }
        }
        
        if (include)
        {
            [self.results addObject:post];
        }
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"minimo-bold" size:28]}];
    [self.navigationItem setTitle:@"Postid"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.feedTableView reloadData];
    [self downloadAndRefreshPosts];
} 

- (void)downloadAndRefreshPosts
{
    NSNumber *minPost = [[PostidManager sharedManager] loadMaxPostIdFromKeychain];
    if (!minPost) {
        minPost = [NSNumber numberWithInteger:0];
    }
    
    [PostidApi fetchPostsWithMinId:minPost completion:^(BOOL success, NSArray *posts, NSNumber *maxId) {
        if (success)
        {
            [[PostidManager sharedManager] cachePosts:posts];
            
            //TODO set new max post id, will get intensive as app gets popular
        }
        
        [self.feedTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FeedCell class]) forIndexPath:indexPath];
    
    Post* post = [self.results objectAtIndex:indexPath.row];
    cell.post = post;
    
    [cell.heartButton setEnabled:NO];
    [cell.fireButton setEnabled:NO];
    [cell.smirkButton setEnabled:NO]; 
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //FeedCell *cell = (FeedCell *)[tableView cellForRowAtIndexPath:indexPath];
    return cellHeight;
}


@end
