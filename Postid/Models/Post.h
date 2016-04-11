//
//  Post.h
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <Realm/RLMRealm.h>
#import "Realm/RLMObject.h"
#import <Realm/RLMArray.h>
#import "UserId.h"

@interface Post : RLMObject

@property NSInteger postId;
@property NSInteger userId; // Poster
@property NSString *imageUrl; //Image key
@property RLMArray<UserId>  *postidForIds;
@property NSInteger viewCount;
@property RLMArray<UserId>  *likedIds;
@property RLMArray<UserId>  *heartedIds;
@property RLMArray<UserId>  *smirkedIds;
@property RLMArray<UserId>  *fireIds;

@property NSInteger likesNeeded;
@property BOOL flagged;
@property BOOL approved;
@property BOOL deleted;

-(void)like:(BOOL)value;
-(void)heart:(BOOL)value;
-(void)smirk:(BOOL)value;
-(void)fire:(BOOL)value;

-(BOOL)liked;
-(BOOL)hearted;
-(BOOL)smirked;
-(BOOL)fired;


@end

RLM_ARRAY_TYPE(Post)