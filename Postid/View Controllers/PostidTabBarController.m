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

@interface PostidTabBarController ()

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
    
    RLMResults *posts = [Post objectsWhere:@"userId != %li AND deleted == NO AND approved == NO AND liked == NO", [[PostidManager sharedManager] currentUser].userId];
    //RLMResults *posts = [Post objectsWhere:@"deleted == NO AND approved == NO AND liked == NO"];
    if ([posts count] > 0 || simulatePost)
        [self performSegueWithIdentifier:@"voting" sender:self];
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
