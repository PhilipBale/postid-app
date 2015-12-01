//
//  HTTPManager.h
//  Postid
//
//  Created by Philip Bale on 8/21/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

extern NSString * const kApiLoginOrRegisterPath;
extern NSString * const kApiLoginWithTokenPath;
extern NSString * const kApiUpdatePhoneNumber;
extern NSString * const kApiSearchForFriends;
extern NSString * const kApiAddFriend;
extern NSString * const kApiDownloadUser;
extern NSString * const kApiMakePost;
extern NSString * const kApiFetchPosts;
extern NSString * const kApiLikePost;
extern NSString * const kApiCommentPost;
extern NSString * const kApiFetchNotifications;
extern NSString * const kApiMarkNotificationRead;
extern NSString * const kAPiSearchForFriendsWithNumbers;

@interface HTTPManager : AFHTTPRequestOperationManager

+ (HTTPManager *)sharedManager;
- (BOOL)wasSuccessfulGet:(id)responseObject;
- (BOOL)wasSuccessfulPost:(id)responseObject;
- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)setRequestHeadersForAPIToken:(NSString *)apiToken;

@end
