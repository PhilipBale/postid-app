//
//  PostPreviewViewController.m
//  Postid
//
//  Created by Philip Bale on 9/7/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "PostPreviewViewController.h"
#import "PostidManager.h"

@interface PostPreviewViewController ()

@end

@implementation PostPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.redoButton.layer.borderWidth = 1;
    self.redoButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.redoButton.layer.cornerRadius = 5;
    self.doneButton.layer.borderWidth = self.redoButton.layer.borderWidth;
    self.doneButton.layer.borderColor = self.redoButton.layer.borderColor;
    self.doneButton.layer.cornerRadius = self.redoButton.layer.cornerRadius;
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *image = [UIImage imageWithData:[[PostidManager sharedManager] lastImageData]];
    [self.previewImage setImage: image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)redoButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"postSelector" sender:self];
}

@end
