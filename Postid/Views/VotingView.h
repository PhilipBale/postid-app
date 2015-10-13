//
//  VotingView.h
//  Postid
//
//  Created by Philip Bale on 9/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "ZLSwipeableView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VotingView : UIImageView

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) UILabel *postTitle;

@end
