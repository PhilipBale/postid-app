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
#import "UserId.h"

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.reportButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //self.reportButton.layer.borderWidth = 1;
    //self.reportButton.layer.cornerRadius = 5;
    
    [self.heartButton setImage:[UIImage imageNamed:@"heart_blue"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.smirkButton setImage:[UIImage imageNamed:@"smirk_blue"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.fireButton setImage:[UIImage imageNamed:@"fire_blue"] forState:UIControlStateSelected | UIControlStateHighlighted];
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
    
    UserId *firstUserId = [post.postidForIds lastObject];
    User *toUser = [[PostidManager sharedManager] userFromCacheWithId:firstUserId.userId];
    self.toUserLabel.text = [toUser name];
    
    [self.heartButton setHighlighted:self.post.hearted];
    [self.fireButton setHighlighted:self.post.fired];
    [self.smirkButton setHighlighted:self.post.smirked];
    [self updateCountLabels];
}

- (void)updateCountLabels
{
    self.heartCountLabel.text = [@([self.post.heartedIds  count]) stringValue];
    self.fireCountLabel.text = [@([self.post.fireIds count]) stringValue];
    self.smirkCountLabel.text = [@([self.post.smirkedIds count]) stringValue];
}

- (IBAction)reportButtonPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose option:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel pressed; do nothing
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Report postid" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSLog(@"Reporting post with id: %li", self.post.postId);
       // Report post
    }]];
    
    [self.parent presentViewController:actionSheet animated:YES completion:nil];
} 

- (IBAction)heartButtonPressed:(id)sender {
    BOOL increment;
    
    if (self.post.hearted) {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post heart:NO];
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post heart:YES];
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
    
    if (self.post.fired) {
        NSLog(@"Unpressing fire");
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post fire:NO];
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        NSLog(@"Pressing fire!");
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post fire:YES];
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
    
    if (self.post.smirked) {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post smirk:NO];
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    } else {
        increment = YES;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [self.post smirk:YES];
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
