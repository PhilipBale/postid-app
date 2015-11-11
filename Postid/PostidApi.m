//
//  PostidApi.m
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "PostidApi.h"
#import "HTTPManager.h"
#import "PostidManager.h"
#import "UserId.h"
#import "Notification.h"
#import <SDWebImagePrefetcher.h>

@implementation PostidApi

+ (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username isLogin:(BOOL)isLogin completion:(void (^)(BOOL, User *, NSDictionary *friendData))completion
{
    NSDictionary *loginOrRegisterParams = @{@"user":@{ @"email": email, @"password": password, @"first_name": firstName, @"last_name": lastName, @"username": username, @"is_login": @(isLogin)}};
    [[HTTPManager sharedManager] GET:kApiLoginOrRegisterPath parameters:loginOrRegisterParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         NSDictionary *friendData = [responseObject objectForKey:@"friends"];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, user, friendData);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
     }];
}

+  (void)loginWithToken:(NSString *)token completion:(void (^)(BOOL, User *, NSDictionary *friendData))completion
{
    NSDictionary *loginWithTokenParams = @{@"user":@{ @"token":token}};
    [[HTTPManager sharedManager] GET:kApiLoginWithTokenPath parameters:loginWithTokenParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         NSDictionary *friendData = [responseObject objectForKey:@"friends"];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, user, friendData);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
     }];
}

+ (void)updatePhoneNumber:(NSString *)phoneNumber forToken:(NSString *)token completion:(void (^)(BOOL, User *))completion;
{
    NSDictionary *updatePhoneNumberParams = @{@"user":@{ @"token":token, @"phone_number":phoneNumber}};
    [[HTTPManager sharedManager] POST:kApiUpdatePhoneNumber parameters:updatePhoneNumberParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, user);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil);
     }];
}

+ (void)searchForFriends:(NSString *)query forToken:(NSString *)token completion:(void (^)(BOOL, NSArray *results))completion
{
    NSDictionary *searchForFriendsParams = @{@"friend":@{ @"query":query}};
    [[HTTPManager sharedManager] GET:kApiSearchForFriends parameters:searchForFriendsParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *results = [responseObject objectForKey:@"search_results"];
         NSMutableArray *users = [[NSMutableArray alloc] init];
         NSInteger currentUserId = [[PostidManager sharedManager] currentUser].userId;
         for (NSObject *result in results)
         {
             User *resultUser = [self userFromDictionary:(NSDictionary *)result];
             if (resultUser.userId != currentUserId)
             {
                 [users addObject:resultUser];
             }
         }
         
         if (completion) completion(YES, users);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil);
     }];
}

+ (void)addFriend:(NSInteger)userId completion:(void (^)(BOOL success, BOOL pending, User *))completion
{
    NSNumber *userIdObject = [NSNumber numberWithInteger:userId];
    NSDictionary *addFriendParams = @{@"friend":@{ @"id":userIdObject}};
    [[HTTPManager sharedManager] POST:kApiAddFriend parameters:addFriendParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         BOOL pending = [[response objectForKey:@"pending"] boolValue];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, pending, user);
     } failure:^(NSError *error) {
         if (completion) completion(NO, NO, nil);
     }];
}

+ (void)downloadUserForId:(NSNumber *)userId completion:(void (^)(BOOL success, User *currentUser, User *downloaded))completion
{
    NSDictionary *downloadUserParams = @{@"user":@{ @"id":userId}};
    [[HTTPManager sharedManager] GET:kApiDownloadUser parameters:downloadUserParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         NSDictionary *downloadedUserData = [responseObject objectForKey:@"downloaded_user"];
         User *currentUser = [self userFromDictionary:response];
         User *downloadedUser = [self userFromDictionary:downloadedUserData];
         
         if (completion) completion(YES, currentUser, downloadedUser);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
     }];
}

+ (void)makePost:(NSString *)urlKey userIdArray:(NSArray *)userIdArray completion:(void (^)(BOOL success))completion
{
    NSDictionary *makePostParams = @{@"post":@{ @"url_key":urlKey, @"user_id_array":userIdArray}};
    [[HTTPManager sharedManager] POST:kApiMakePost parameters:makePostParams success:^(NSDictionary *responseObject)
     {
         
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

+  (void)fetchPostsWithMinId:(NSNumber *)minId completion:(void (^)(BOOL, NSArray *posts, NSNumber *maxId))completion
{
    NSDictionary *fetchPostsParams = @{@"post":@{ @"min_id":minId}};
    [[HTTPManager sharedManager] GET:kApiFetchPosts parameters:fetchPostsParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *results = [responseObject objectForKey:@"posts"];
         NSNumber *maxId = [responseObject objectForKey:@"max_id"];
         
         NSMutableArray *posts = [[NSMutableArray alloc] init];
         NSMutableArray *postImageUrls = [[NSMutableArray alloc] init];
         NSMutableArray *uniqueUsers = [[NSMutableArray alloc] init];
         User *currentUser = [[PostidManager sharedManager] currentUser];
         
         for (NSDictionary *result in results)
         {
             NSArray *postsUsers = [result objectForKey:@"users"];
             for (NSDictionary *user in postsUsers) {
                 NSInteger userId = [[user objectForKey:@"id"] integerValue];
                 NSNumber *userIdNum = @(userId);
                 
                 // Prefetch up-to-date users
                 if (![uniqueUsers containsObject:userIdNum] && userId != currentUser.userId)
                 {
                     //prefetch
                     [uniqueUsers addObject:userIdNum];
                     [[PostidManager sharedManager] downloadAndAddUser:userIdNum toFriendGroup:FriendGroupUnknown ofCurrentUser:nil];
                 }
             }
             
             Post *resultPost = [self postFromDictionary:result];
             [postImageUrls addObject:[NSURL URLWithString:resultPost.imageUrl]];
             [posts addObject:resultPost];
         }
         
         [[SDWebImagePrefetcher  sharedImagePrefetcher] prefetchURLs:postImageUrls];
         
         if (completion) completion(YES, posts, maxId);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
     }];
}

+ (void)likePost:(NSNumber *)postId completion:(void (^)(BOOL success))completion
{
    NSDictionary *likePostParams = @{@"post":@{ @"post_id":postId}};
    [[HTTPManager sharedManager] POST:kApiLikePost parameters:likePostParams success:^(NSDictionary *responseObject)
     {
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

+ (void)commentPost:(NSNumber *)postId  comment:(CommentType)commentType increment:(BOOL)increment completion:(void (^)(BOOL success))completion
{
    NSNumber *incrementNum = increment ? @(1) : @(-1);
    NSString *type = nil;
    switch (commentType)
    {
        case CommentTypeHeart:
            type = @"HEART";
            break;
        case CommentTypeFire:
            type = @"FIRE";
            break;
        case CommentTypeSmirk:
            type = @"SMIRK";
            break;
        default:
            break;
    }
    
    NSDictionary *commentPostParams = @{@"post":@{ @"post_id":postId, @"type":type, @"increment":incrementNum}};
    
    [[HTTPManager sharedManager] POST:kApiCommentPost parameters:commentPostParams success:^(NSDictionary *responseObject)
     {
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

+  (void)fetchNotificationsWithMinId:(NSNumber *)minId completion:(void (^)(BOOL, NSArray *notifications, NSNumber *maxId))completion
{
    NSDictionary *fetchPostsParams = @{@"notification":@{ @"min_id":minId}};
    [[HTTPManager sharedManager] GET:kApiFetchNotifications parameters:fetchPostsParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *results = [responseObject objectForKey:@"notifications"];
         NSNumber *maxId = [responseObject objectForKey:@"max_id"];
         
         NSMutableArray *notifications = [[NSMutableArray alloc] init];
         NSMutableArray *uniquePosts = [[NSMutableArray alloc] init];
         NSMutableArray *uniqueUsers = [[NSMutableArray alloc] init];
         User *currentUser = [[PostidManager sharedManager] currentUser];
         
         
         
         for (NSDictionary *result in results)
         {
             Notification *notificationResult = [self notificationFromDictionary:result];
             NSNumber *fromId = @(notificationResult.fromId);
             NSNumber *postId = @(notificationResult.postId);
             
             if (![uniqueUsers containsObject:fromId] && [fromId integerValue] != currentUser.userId)
             {
                 [uniqueUsers addObject:fromId];
                 [[PostidManager sharedManager] downloadAndAddUser:fromId toFriendGroup:FriendGroupUnknown ofCurrentUser:nil];
             }
             
             if (postId != nil && ![uniquePosts containsObject:postId])
             {
                 [uniquePosts addObject:fromId];
                 //TODO cache post
             }
             
             [notifications addObject:notificationResult];
         }
         
         if (completion) completion(YES, notifications, maxId);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
     }];
}

+  (void)markNotificationViewed:(NSNumber *)notificationId completion:(void (^)(BOOL success))completion
{
    NSDictionary *markNotificationViewedParam = @{@"notification":@{ @"notification_id":notificationId}};
    
    [[HTTPManager sharedManager] POST:kApiMarkNotificationRead parameters:markNotificationViewedParam success:^(NSDictionary *responseObject)
     {
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

+ (User *)userFromDictionary:(NSDictionary *)dictionary
{
    User *user = [[User alloc] init];
    user.userId = [[dictionary objectForKey:@"id"] integerValue];
    user.email = [dictionary objectForKey:@"email"];;
    user.token = [dictionary objectForKey:@"token"];
    user.firstName = [dictionary objectForKey:@"first_name"];
    user.lastName = [dictionary objectForKey:@"last_name"];
    user.username = [dictionary objectForKey:@"username"];
    user.postsCreated = [[dictionary objectForKey:@"posts_created"] integerValue];
    user.admin = [[dictionary objectForKey:@"admin"] integerValue] ? YES : NO;
    user.phoneNumber = [dictionary objectForKey:@"phone_number"];
    user.imageUrl = [dictionary objectForKey:@"image_url"];
    return user;
}

+ (Post *)postFromDictionary:(NSDictionary *)dictionary
{
    Post *post = [[Post alloc] init];
    post.postId = [[dictionary objectForKey:@"id"] integerValue];
    post.userId = [[dictionary objectForKey:@"user_id"] integerValue];
    post.imageUrl = [dictionary objectForKey:@"image_url"];
    post.viewCount = [[dictionary objectForKey:@"view_count"] integerValue];
    post.heartCount = [[dictionary objectForKey:@"heart_count"] integerValue];
    post.smirkCount = [[dictionary objectForKey:@"smirk_count"] integerValue];
    post.fireCount = [[dictionary objectForKey:@"fire_count"] integerValue];
    post.likes = [[dictionary objectForKey:@"likes"] integerValue];
    post.likesNeeded = [[dictionary objectForKey:@"likes_needed"] integerValue];
    post.flagged = [[dictionary objectForKey:@"flagged"] boolValue];
    post.approved = [[dictionary objectForKey:@"approved"] boolValue];
    post.deleted = [[dictionary objectForKey:@"deleted"] boolValue];
    
    
    NSArray *postsUsers = [dictionary objectForKey:@"users"];
    
    for (NSDictionary *user in postsUsers) {
        NSInteger userIdValue = [[user objectForKey:@"id"] integerValue];
        UserId *userIdModel = [[UserId alloc] init];
        userIdModel.userId = userIdValue;
        [post.postidForIds addObject:userIdModel];
    }
    
    return post;
}

+ (Notification *)notificationFromDictionary:(NSDictionary *)dictionary
{
    Notification *notification = [[Notification alloc] init];
    notification.notificationId = [[dictionary objectForKey:@"id"] integerValue];
    notification.userId = [[dictionary objectForKey:@"user_id"] integerValue];
    notification.fromId = [[dictionary objectForKey:@"from_id"] integerValue];
    notification.message = [dictionary objectForKey:@"message"];
    notification.postId = [[dictionary objectForKey:@"post_id"] integerValue];
    notification.type = [[dictionary objectForKey:@"type"] integerValue];
    notification.viewed = [[dictionary objectForKey:@"viewed"] boolValue];
    notification.date = [[dictionary objectForKey:@"created_at"] integerValue];
    
    return notification;
}

@end
