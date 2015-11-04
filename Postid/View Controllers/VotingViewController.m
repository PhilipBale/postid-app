//
//  VotingViewController.m
//  Postid
//
//  Created by Philip Bale on 9/28/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "VotingViewController.h"
#import "ZLSwipeableView.h"
#import "VotingView.h"
#import "PostidManager.h"
#import "PostidApi.h"
#import <Realm/RLMRealm.h>
#import "GeneralUtilities.h"

@interface VotingViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>
{
    
}

@property(nonatomic,strong) ZLSwipeableView *swipeableView;
@property(nonatomic,strong) NSMutableArray *postsToVoteOn;
@property (nonatomic) NSUInteger voteIndex;

@end

@implementation VotingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.postsToVoteOn = [Post allObjects]
    self.postsToVoteOn = [GeneralUtilities mutableArrayFromRealmResults:[Post objectsWhere:@"userId != %li AND deleted == NO AND approved == NO AND liked == NO", [[PostidManager sharedManager] currentUser].userId]];
    //self.postsToVoteOn = [GeneralUtilities mutableArrayFromRealmResults:[Post objectsWhere:@"deleted == NO AND approved == NO AND liked == NO"]];

    self.swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.view.frame];
    self.swipeableView.dataSource = self;
    self.swipeableView.delegate = self;
    
    [self.view addSubview:self.swipeableView];
}

-(VotingView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    if (self.voteIndex >= self.postsToVoteOn.count)
        return nil;
    
    Post *nextPost = [self.postsToVoteOn objectAtIndex:self.voteIndex];
    VotingView *view = [[VotingView alloc] initWithFrame:swipeableView.frame];
    view.post = nextPost;
    
    self.voteIndex++;
    
    return view;
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(VotingView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    
    Post *post = view.post;
    BOOL liked = NO;
    NSLog(@"Swiped post %li", view.post.postId);
    if (direction == 2 || direction == 4)
    {
        NSLog(@"Did swipe positive");
        liked = YES;
        [PostidApi likePost:[NSNumber numberWithInteger:post.postId] completion:^(BOOL success) {
           if (!success)
           {
               NSLog(@"This is awkward.  Failed to like!");
           }
        }];
    }
    else
    {
        NSLog(@"Did swipe negative");
    }
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    {
        post.liked = YES;
        if (liked)
            post.likes++;
        if (post.likes > post.likesNeeded / 2) {
            post.approved = YES;
        }
        [Post createOrUpdateInDefaultRealmWithValue:post];
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    if ([post isEqual:[self.postsToVoteOn lastObject]]) {
        NSLog(@"Attemping to dismiss!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }
}

- (void)vote:(BOOL)up
{
    
} 

@end
