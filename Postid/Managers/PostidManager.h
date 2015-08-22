//
//  PostidManager.h
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface PostidManager : NSObject

@property (nonatomic, strong) User *currentUser;

+ (PostidManager *)sharedManager;

- (void)logout;
- (void)saveTokenToKeychain:(NSString *)token;
- (NSString *)loadTokenFromKeychain;
- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object;


@end
