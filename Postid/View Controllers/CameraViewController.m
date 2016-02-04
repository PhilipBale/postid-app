//
//  CameraViewController.m
//  Postid
//
//  Created by Philip Bale on 8/23/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "CameraViewController.h"
#import "PostidManager.h"
#import "PostidApi.h"
#import <MBSegue.h>
#import <MBFadeSegue.h>

@interface CameraViewController () <CACameraSessionDelegate>
@property (nonatomic, strong) CameraSessionView *cameraView;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    NSLog(@"Camera view loaded");
    [super viewDidLoad];
    self.cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    self.cameraView.delegate = self;
    [self.cameraView setTopBarColor:UIColorFromRGB(0x225c70)];
    [self.cameraView hideDismissButton];
    [self.view addSubview:self.cameraView];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCamera:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCamera:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    //Use the image's data that is received
    NSLog(@"Image captured");
    [[PostidManager sharedManager] setLastImageData:imageData];
    [self performSegueWithIdentifier:@"previewImage" sender:self];
}

-(void)didPressCamera
{
    BOOL breakFunc = YES;
    #if TARGET_IPHONE_SIMULATOR
    breakFunc = NO;
    #endif
    
    if (breakFunc) return;
    
    UIImage *fakeImage = [UIImage imageNamed:@"lebron"];
    [[PostidManager sharedManager] setLastImageData:UIImageJPEGRepresentation(fakeImage, 0.7)];
    [self performSegueWithIdentifier:@"previewImage" sender:self];
}

- (IBAction)dismissCamera:(id)sender
{
    NSLog(@"Swiped");
    [self performSegueWithIdentifier:@"mainTabBar" sender:self];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController
                                      fromViewController:(UIViewController *)fromViewController
                                              identifier:(NSString *)identifier
{
    MBSegue *fade = [[MBFadeSegue alloc] initWithIdentifier:identifier
                                                     source:fromViewController
                                                destination:toViewController];
    fade.type = MBSegueTypeDismiss;
    return fade;
    
    
}

@end
