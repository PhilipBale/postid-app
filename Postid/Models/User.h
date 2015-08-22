//
//  User.h
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Realm/Realm.h>

@interface User : RLMObject

@property NSInteger userId;
@property NSString *email;
@property NSString *token;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *username;
@property NSInteger postsCreated;
@property BOOL admin;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<User>
RLM_ARRAY_TYPE(User)
