//
//  PostidTabBarController.m
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PostidTabBarController.h"
#import "Post.h"
#import "PostidManager.h"
#import <MBSegue.h>
#import <MBFadeSegue.h>
#import "PostidApi.h"
#import "VotingViewController.h"

@interface PostidTabBarController ()

@property (nonatomic, strong) NSMutableArray<Post> *postsForVoting;

@end

@implementation PostidTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissToCamera:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissToCamera:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(3, 0, -3, 0);
    }];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL simulatePost = NO;
    
    [PostidApi fetchPostsWithMinId:0 completion:^(BOOL success, NSArray<Post> *posts, NSNumber *maxId) {
        self.postsForVoting = [[NSMutableArray<Post> alloc] init];
        
        
        for (Post *post in posts)
        {
            if (![post liked] && ![post approved])
            {
                [self.postsForVoting addObject:post];
            }
        }
        
        if ([self.postsForVoting count] > 0 || simulatePost)
        {
            
            [self performSegueWithIdentifier:@"voting" sender:self];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"voting"])
    { 
        VotingViewController *vc = [segue destinationViewController];
        
        [vc setPosts:self.postsForVoting];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissToCamera:(id)sender
{
    NSLog(@"Swiped, dismissing to camera");
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"unwindToCamera" sender:self];
    //self unwindForSegue:<#(nonnull UIStoryboardSegue *)#> towardsViewController:<#(nonnull UIViewController *)#>
}



@end
