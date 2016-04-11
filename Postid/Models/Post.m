//
//  Post.m
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "Post.h"
#import "PostidManager.h"

@implementation Post

+ (NSString *)primaryKey
{
    return @"postId";
}

-(void)like:(BOOL)value
{
    NSInteger exitingUserIndex = -1;
    NSInteger currentUserId = [[[PostidManager sharedManager] currentUser] userId];
    
    for (NSInteger i = 0; i < self.likedIds.count; i++) {
        if ([self.likedIds[i] userId] == currentUserId) {
            exitingUserIndex = i;
        }
    }
    
    if (value) {
        if (exitingUserIndex < 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                UserId *userId = [[UserId alloc] init];
                userId.userId = currentUserId;
                [UserId createOrUpdateInDefaultRealmWithValue:userId];
                [self.likedIds addObject:userId];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    } else {
        if (exitingUserIndex >= 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                [self.likedIds removeObjectAtIndex:exitingUserIndex];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}

-(void)heart:(BOOL)value
{
    NSInteger exitingUserIndex = -1;
    NSInteger currentUserId = [[[PostidManager sharedManager] currentUser] userId];
    
    for (NSInteger i = 0; i < self.heartedIds.count; i++) {
        if ([self.heartedIds[i] userId] == currentUserId) {
            exitingUserIndex = i;
        }
    }
    
    if (value) {
        if (exitingUserIndex < 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                UserId *userId = [[UserId alloc] init];
                userId.userId = currentUserId;
                [UserId createOrUpdateInDefaultRealmWithValue:userId];
                [self.heartedIds addObject:userId];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    } else {
        if (exitingUserIndex >= 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                [self.heartedIds removeObjectAtIndex:exitingUserIndex];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}

-(void)smirk:(BOOL)value
{
    NSInteger exitingUserIndex = -1;
    NSInteger currentUserId = [[[PostidManager sharedManager] currentUser] userId];
    
    for (NSInteger i = 0; i < self.smirkedIds.count; i++) {
        if ([self.smirkedIds[i] userId] == currentUserId) {
            exitingUserIndex = i;
        }
    }
    
    if (value) {
        if (exitingUserIndex < 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                UserId *userId = [[UserId alloc] init];
                userId.userId = currentUserId;
                [UserId createOrUpdateInDefaultRealmWithValue:userId];
                [self.smirkedIds addObject:userId];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    } else {
        if (exitingUserIndex >= 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                [self.smirkedIds removeObjectAtIndex:exitingUserIndex];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}

-(void)fire:(BOOL)value
{
    NSInteger exitingUserIndex = -1;
    NSInteger currentUserId = [[[PostidManager sharedManager] currentUser] userId];
    
    for (NSInteger i = 0; i < self.fireIds.count; i++) {
        if ([self.fireIds[i] userId] == currentUserId) {
            exitingUserIndex = i;
        }
    }
    
    if (value) {
        if (exitingUserIndex < 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                UserId *userId = [[UserId alloc] init];
                userId.userId = currentUserId;
                [UserId createOrUpdateInDefaultRealmWithValue:userId];
                [self.fireIds addObject:userId];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    } else {
        if (exitingUserIndex >= 0) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                [self.fireIds removeObjectAtIndex:exitingUserIndex];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}


-(BOOL)liked
{
    for (UserId *userId in self.likedIds)
    {
        if ([userId userId] == [[[PostidManager sharedManager] currentUser] userId]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)hearted
{
    for (UserId *userId in self.heartedIds)
    {
        if ([userId userId] == [[[PostidManager sharedManager] currentUser] userId]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)smirked
{
    for (UserId *userId in self.smirkedIds)
    {
        if ([userId userId] == [[[PostidManager sharedManager] currentUser] userId]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)fired
{
    for (UserId *userId in self.fireIds)
    {
        if ([userId userId] == [[[PostidManager sharedManager] currentUser] userId]) {
            return YES;
        }
    }
    
    return NO;
}

@end
