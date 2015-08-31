//
//  PostidApi.m
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "PostidApi.h"
#import "HTTPManager.h"

@implementation PostidApi

+ (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username completion:(void (^)(BOOL, User *))completion
{
    NSDictionary *loginOrRegisterParams = @{@"user":@{ @"email": email, @"password": password, @"first_name": firstName, @"last_name": lastName, @"username": username}};
    [[HTTPManager sharedManager] GET:kApiLoginOrRegisterPath parameters:loginOrRegisterParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, user);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil);
     }];
}
+  (void)loginWithToken:(NSString *)token completion:(void (^)(BOOL, User *))completion
{
    NSDictionary *loginWithTokenParams = @{@"user":@{ @"token":token}};
    [[HTTPManager sharedManager] GET:kApiLoginWithTokenPath parameters:loginWithTokenParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         User *user = [self userFromDictionary:response];
         
         if (completion) completion(YES, user);
     } failure:^(NSError *error) {
         if (completion) completion(NO, nil);
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
    return user;
}

@end
