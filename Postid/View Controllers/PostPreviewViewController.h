//
//  PostPreviewViewController.h
//  Postid
//
//  Created by Philip Bale on 9/7/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostPreviewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage; 

@end
