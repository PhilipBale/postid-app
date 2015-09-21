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

@implementation PostidApi

+ (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username completion:(void (^)(BOOL, User *, NSDictionary *friendData))completion
{
    NSDictionary *loginOrRegisterParams = @{@"user":@{ @"email": email, @"password": password, @"first_name": firstName, @"last_name": lastName, @"username": username}};
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
    [[HTTPManager sharedManager] GET:kApiLoginWithTokenPath parameters:fetchPostsParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *results = [responseObject objectForKey:@"posts"];
         NSNumber *maxId = [responseObject objectForKey:@"max_id"];
         
         NSMutableArray *posts = [[NSMutableArray alloc] init];
         for (NSObject *result in results)
         {
             Post *resultPost = [self postFromDictionary:(NSDictionary *)result];
             [posts addObject:resultPost];
             
         }
         
         if (completion) completion(YES, posts, maxId);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil, nil);
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

@end
