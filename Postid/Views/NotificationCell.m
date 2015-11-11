//
//  NotificationCell.m
//  Postid
//
//  Created by Philip Bale on 11/11/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setNotification:(Notification *)notification
{
    _notification = notification;
    self.messageLabel.text = notification.message;
    
    //fire viewed if not viewed already
   
    /*NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", post.imageUrl];
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:url]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    User *poster = [[PostidManager sharedManager] userFromCacheWithId:post.userId];
    self.fromUserLabel.text = poster.username;
    
    UserId *firstUserId = [post.postidForIds lastObject];
    User *toUser = [[PostidManager sharedManager] userFromCacheWithId:firstUserId.userId];
    self.toUserLabel.text = [toUser name];*/
    
}


@end
