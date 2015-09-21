//
//  User.m
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "User.h"
#import "PostidManager.h"

@implementation User

+ (NSString *)primaryKey
{
    return @"userId";
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

-(BOOL)friendsWithPrimaryUser
{
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    RLMResults *matches = [currentUser.friends objectsWhere:@"userId = %@", [NSNumber numberWithInteger:self.userId]];
    
    return ([matches count] > 0);
}

-(BOOL)pendingFriendsWithPrimaryUser
{
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    RLMResults *matches = [currentUser.pendingFriends objectsWhere:@"userId = %@", [NSNumber numberWithInteger:self.userId]];
    
    return ([matches count] > 0);
}

-(BOOL)requestedFriendsWithPrimaryUser
{
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    RLMResults *matches = [currentUser.requestedFriends objectsWhere:@"userId = %@", [NSNumber numberWithInteger:self.userId]];
    
    return ([matches count] > 0);
}

@end
