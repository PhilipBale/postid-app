//
//  FeedViewController.m
//  Postid
//
//  Created by Philip Bale on 8/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"
#import "PostidApi.h"
#import "PostidManager.h"

@interface FeedViewController ()
{
    CGFloat cellHeight;
}
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    cellHeight = [[UIScreen mainScreen] bounds].size.height / 640 * 275;
    
    [self downloadAndRefreshPosts];
    // TODO pull data
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
            // cache posts
            
            //TODO set new max post id
        }
        
        
        [self.feedTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FeedCell class]) forIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //FeedCell *cell = (FeedCell *)[tableView cellForRowAtIndexPath:indexPath];
    return cellHeight;
}


@end
