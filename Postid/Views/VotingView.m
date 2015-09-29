//
//  VotingView.m
//  Postid
//
//  Created by Philip Bale on 9/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "VotingView.h"
#import "SDImageCache.h"
#import "SDImageCache+Private.h"

@implementation VotingView

- (void)setPost:(Post *)post
{
    _post = post;
    
    SDImageCache *cache = [[SDImageCache alloc] init];
    NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", post.imageUrl];
    NSString *path = [cache defaultCachePathForKey:url];
    //[self setImage:[UIImage imageWithContentsOfFile:path]];
    [self sd_setImageWithURL:[NSURL URLWithString:url]];
    //[self sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:url] andPlaceholderImage:[UIImage imageNamed:@"placeholder.png"] options:0 progress:nil completed:nil];
//    User *poster = [[PostidManager sharedManager] userFromCacheWithId:post.userId];
//    self.fromUserLabel.text = poster.username;
}

@end
