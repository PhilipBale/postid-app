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
#import "FeedViewController.h"

@interface FeedCell : UITableViewCell

@property (nonatomic, strong) FeedViewController *parent; //hack

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *toUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (nonatomic, strong) Post *post;

@property (weak, nonatomic) IBOutlet UIButton *fireButton;
@property (weak, nonatomic) IBOutlet UILabel *fireCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *smirkButton;
@property (weak, nonatomic) IBOutlet UILabel *smirkCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UILabel *heartCountLabel;

@end
