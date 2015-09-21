//
//  FeedCell.m
//  Postid
//
//  Created by Philip Bale on 8/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FeedCell.h"
#import "PostidManager.h"
#import "User.h"

@implementation FeedCell

- (void)awakeFromNib {
    // Initialization code
    self.reportButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.reportButton.layer.borderWidth = 1;
    self.reportButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)post
{
    _post = post;
    NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", post.imageUrl];
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:url]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    User *poster = [[PostidManager sharedManager] userFromCacheWithId:post.userId];
    self.fromUserLabel.text = poster.username;
}

- (IBAction)reportButtonPressed:(id)sender {
}

@end
