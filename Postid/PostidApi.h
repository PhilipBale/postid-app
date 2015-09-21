//
//  PostidApi.h
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface PostidApi : NSObject

+ (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username completion:(void (^)(BOOL, User *, NSDictionary *friendData))completion;
+ (void)loginWithToken:(NSString *)token completion:(void (^)(BOOL, User *, NSDictionary *friendData))completion;
+ (void)updatePhoneNumber:(NSString *)phoneNumber forToken:(NSString *)token completion:(void (^)(BOOL, User *))completion;
+ (void)searchForFriends:(NSString *)query forToken:(NSString *)token completion:(void (^)(BOOL, NSArray *results))completion;
+ (void)addFriend:(NSInteger)userId completion:(void (^)(BOOL success, BOOL pending, User *))completion;
+ (void)downloadUserForId:(NSNumber *)userId completion:(void (^)(BOOL success, User *currentUser, User *downloaded))completion;
+ (void)makePost:(NSString *)urlKey userIdArray:(NSArray *)userIdArray completion:(void (^)(BOOL success))completion;
+  (void)fetchPostsWithMinId:(NSNumber *)minId completion:(void (^)(BOOL, NSArray *posts, NSNumber *maxId))completion;
@end
