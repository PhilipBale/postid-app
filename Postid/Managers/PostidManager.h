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

typedef NS_ENUM(NSInteger, FriendGroup) {
    FriendGroupRequest,
    FriendGroupPending,
    FriendGroupFriends
};

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSData *lastImageData;

+ (PostidManager *)sharedManager;

- (void)logout;
- (void)saveTokenToKeychain:(NSString *)token;
- (NSString *)loadTokenFromKeychain;
- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object;

- (User *)currentUserFromRealm;
- (User *)userFromCacheWithId:(NSInteger)userId;
- (void)cacheFriendsData:(NSDictionary *)dictionary;

- (void)makePostForUsers:(NSArray *)userIds withImageData:(NSData *)imageData completion:(void (^)(BOOL success))completion;

@end
