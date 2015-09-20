//
//  SearchDisplayViewController.m
//  Postid
//
//  Created by Philip Bale on 9/8/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FriendSearchController.h"

@interface FriendSearchController ()

@end

@implementation FriendSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"Search controller dissapearing");
    
    // Hack to prevent black screen on nav
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)setActive:(BOOL)active
{
    [super setActive:active];
    //[self.navigationController setNavigationBarHidden: NO animated: NO];
    [self.parentViewController.navigationController setNavigationBarHidden:NO];
}


@end
