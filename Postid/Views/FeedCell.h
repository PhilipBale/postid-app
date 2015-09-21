//
//  FeedCell.h
//  Postid
//
//  Created by Philip Bale on 8/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Post.h"

@interface FeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *toUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (nonatomic, strong) Post *post;

@end
