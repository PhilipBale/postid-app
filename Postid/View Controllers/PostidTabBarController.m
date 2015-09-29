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
#import <Realm.h>

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
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    RLMResults *posts = [Post objectsWhere:@"userId != %li AND deleted == NO AND approved == NO AND liked == NO", [[PostidManager sharedManager] currentUser].userId];
    //RLMResults *posts = [Post objectsWhere:@"deleted == NO AND approved == NO AND liked == NO"];
    if ([posts count] > 0)
        [self performSegueWithIdentifier:@"voting" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissToCamera:(id)sender
{
    NSLog(@"Swiped");
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"unwindToCamera" sender:self];
    //self unwindForSegue:<#(nonnull UIStoryboardSegue *)#> towardsViewController:<#(nonnull UIViewController *)#>
}

@end