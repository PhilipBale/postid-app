//
//  Post.h
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "RLMObject.h"

@interface Post : RLMObject

@property NSInteger postId;
@property NSInteger userId; // Poster
@property NSString *imageUrl; //Image key
@property NSInteger viewCount;
@property NSInteger heartCount;
@property NSInteger smirkCount;
@property NSInteger fireCount;
@property NSInteger likes;
@property NSInteger likesNeeded;
@property BOOL flagged;
@property BOOL approved;
@property BOOL deleted;

@property BOOL liked; //local

@property BOOL heartPressed;
@property BOOL smirkPressed;
@property BOOL firePressed;
@property BOOL likePressed;

@end

RLM_ARRAY_TYPE(Post)