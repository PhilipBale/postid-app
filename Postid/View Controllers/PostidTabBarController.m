//
//  PostidTabBarController.m
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PostidTabBarController.h"

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
