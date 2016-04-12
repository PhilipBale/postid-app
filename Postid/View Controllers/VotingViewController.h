//
//  VotingViewController.h
//  Postid
//
//  Created by Philip Bale on 9/28/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface VotingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (nonatomic, strong) NSArray<Post> *posts;

@end
