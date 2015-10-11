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
#import "PostidApi.h"

@implementation FeedCell

- (void)awakeFromNib {
    // Initialization code
    self.reportButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.reportButton.layer.borderWidth = 1;
    self.reportButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPost:(Post *)post
{
    _post = post;
    NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", post.imageUrl];
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:url]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    User *poster = [[PostidManager sharedManager] userFromCacheWithId:post.userId];
    self.fromUserLabel.text = poster.username;
    
    [self.heartButton setHighlighted:self.post.heartPressed];
    [self.fireButton setHighlighted:self.post.firePressed];
    [self.smirkButton setHighlighted:self.post.smirkPressed];
    [self updateCountLabels];
}

- (void)updateCountLabels
{
    self.heartCountLabel.text = [@(self.post.heartCount) stringValue];
    self.fireCountLabel.text = [@(self.post.fireCount) stringValue];
    self.smirkCountLabel.text = [@(self.post.smirkCount) stringValue];
}

- (IBAction)reportButtonPressed:(id)sender {
    
}

//TODO configure server for pressing!!!

- (IBAction)heartButtonPressed:(id)sender {
    BOOL increment;
    
    if (self.post.heartPressed) {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setHeartPressed:NO];
            self.post.heartCount -= 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setHeartPressed:YES];
            self.post.heartCount += 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.heartButton setHighlighted:YES];
        });
    }
    
    [PostidApi commentPost:@(self.post.postId) comment:CommentTypeHeart increment:increment completion:^(BOOL success) {
        
    }];
    
    [self updateCountLabels];
}

- (IBAction)fireButtonPressed:(id)sender {
    BOOL increment = NO;
    
    if (self.post.firePressed) {
        NSLog(@"Unpressing fire");
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setFirePressed:NO];
            self.post.fireCount -= 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        NSLog(@"Pressing fire!");
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setFirePressed:YES];
            self.post.fireCount += 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.fireButton setHighlighted:YES];
        });
    }
    
    [PostidApi commentPost:@(self.post.postId) comment:CommentTypeFire increment:increment completion:^(BOOL success) {
        
    }];
    
    [self updateCountLabels];
}

- (IBAction)smirkButtonPressed:(id)sender {
    BOOL increment = NO;
    
    if (self.post.smirkPressed) {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setSmirkPressed:NO];
            self.post.smirkCount -= 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post setSmirkPressed:YES];
            self.post.smirkCount += 1;
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.smirkButton setHighlighted:YES];
        });
    }
    
    [PostidApi commentPost:@(self.post.postId) comment:CommentTypeSmirk increment:increment completion:^(BOOL success) {
        
    }];
    
    [self updateCountLabels];
}

@end
