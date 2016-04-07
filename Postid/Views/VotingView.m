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
#import "PostidManager.h"

@interface VotingView ()
@property CGPoint startLocation;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@end

@implementation VotingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.postTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,25, [[UIScreen mainScreen] bounds].size.width, 40)];
    
    [self.postTitle setTextAlignment:NSTextAlignmentCenter];
    [self.postTitle setText:@"Test preview"];
    [self.postTitle setTextColor:[UIColor whiteColor]];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
    CGFloat imageWidth = screenRect.size.width / 1.5;
    
    CGRect voteFrame = CGRectMake(screenRect.size.width / 2 - imageWidth / 2, screenRect.size.height / 2 - imageWidth / 2, imageWidth, imageWidth);
    CGRect upvoteFrame = CGRectMake(screenRect.size.width - imageWidth - imageWidth / 4, screenRect.size.height / 2 - imageWidth / 2, imageWidth, imageWidth);
    
    self.downvoteImageView = [[UIImageView alloc] initWithFrame:voteFrame];
    [self.downvoteImageView setImage:[UIImage imageNamed:@"thumb_down"]];
    
    self.upvoteImageView = [[UIImageView alloc] initWithFrame:voteFrame];
    [self.upvoteImageView setImage:[UIImage imageNamed:@"thumb_up"]];
    
    [self addSubview:self.downvoteImageView];
    [self addSubview:self.upvoteImageView];
    [self addSubview:self.postTitle];
    
    [self stopSwiping];
    
    NSLog(@"Initializing voting view");
    
    return self;
}


- (void)setPost:(Post *)post
{
    _post = post;
    
    SDImageCache *cache = [[SDImageCache alloc] init];
    NSString *url = [NSString stringWithFormat:@"https://s3.amazonaws.com/postidimages/%@", post.imageUrl];
    NSString *path = [cache defaultCachePathForKey:url];
    //[self setImage:[UIImage imageWithContentsOfFile:path]];
    
    bool debugImage = YES;
    if (debugImage) {
        UIImage *sample = [UIImage imageNamed:@"lebron"];
        [self setImage:sample];
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    
    PostidManager *man = [PostidManager sharedManager];
    User *poster = [man userFromCacheWithId:self.post.userId];
    
    [self setBackgroundColor:[UIColor blackColor]];
    
    [self.postTitle setText:[NSString stringWithFormat:@"Postid by %@", poster.username]];
    //[self sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:url] andPlaceholderImage:[UIImage imageNamed:@"placeholder.png"] options:0 progress:nil completed:nil];
    //    User *poster = [[PostidManager sharedManager] userFromCacheWithId:post.userId];
    //    self.fromUserLabel.text = poster.username;
}

-(void)swiping:(CGPoint)translation {
    BOOL swipeRight = translation.y < 0;
    NSLog(@"Swipe right %@", @(self.startLocation.y));
    
    CGFloat maxTranslate = swipeRight ? self.startLocation.y : self.screenHeight - self.startLocation.y;
    CGFloat alpha = fabs(translation.y) / fabs(maxTranslate);
    
    alpha *= 1.75; // increase
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (swipeRight) {
            [self.upvoteImageView setHidden:!swipeRight];
            [self.upvoteImageView setAlpha:alpha];
        } else {
            [self.downvoteImageView setHidden:swipeRight];
            [self.downvoteImageView setAlpha:alpha];
        }
    });
}

-(void)startSwiping:(CGPoint)location
{
    self.startLocation = location;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downvoteImageView setAlpha:0];
        [self.upvoteImageView setAlpha:0];
    });
}

-(void)stopSwiping
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downvoteImageView setHidden:YES];
        [self.downvoteImageView setAlpha:1];
        [self.upvoteImageView setHidden:YES];
        [self.upvoteImageView setAlpha:1];
    });
}

@end
