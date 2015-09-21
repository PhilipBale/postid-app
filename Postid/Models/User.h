//
//  User.h
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "Realm/Realm.h"

@class User;
@protocol User;

@interface User : RLMObject

@property NSInteger userId;
@property NSString *email;
@property NSString *token;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *username;
@property NSString *phoneNumber;
@property NSInteger postsCreated;
@property BOOL admin;
@property NSString *imageUrl;

@property RLMArray<User> *friends;
@property RLMArray<User> *pendingFriends;
@property RLMArray<User> *requestedFriends;

@property (readonly) NSString *name;
@property (readonly) BOOL friendsWithPrimaryUser;
@property (readonly) BOOL pendingFriendsWithPrimaryUser;
@property (readonly) BOOL requestedFriendsWithPrimaryUser;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<User>
RLM_ARRAY_TYPE(User)
