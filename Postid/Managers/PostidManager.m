//
//  PostidManager.m
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "PostidManager.h"
#import "HTTPManager.h"
#import "PostidApi.h"
#import "AppDelegate.h"

@implementation PostidManager



+ (PostidManager *)sharedManager
{
    static dispatch_once_t pred;
    static PostidManager *_sharedManager = nil;
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

-(void)setCurrentUser:(User *)currentUser
{
    if (!currentUser) return;
    
    //Persist non-server variables
    User *oldUser = [User objectForPrimaryKey:[NSNumber numberWithInteger:currentUser.userId]];
    if (oldUser)
    {
        currentUser.friends = oldUser.friends;
        currentUser.pendingFriends = oldUser.pendingFriends;
        currentUser.requestedFriends = oldUser.requestedFriends;
    }
    
    _currentUser = currentUser;
    
    [self expressDefaultRealmWrite:currentUser];
    [self saveTokenToKeychain:currentUser.token];
    [[HTTPManager sharedManager] setRequestHeadersForAPIToken:currentUser.token];
}

- (void)logout
{
    self.currentUser = nil;
    [self saveTokenToKeychain:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
    [tabBarController dismissViewControllerAnimated:true completion:nil];
}

- (void)saveTokenToKeychain:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

- (NSString *)loadTokenFromKeychain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"token"];
}

- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object
{
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    RLMObject *returnObj = [object.class createOrUpdateInRealm:[RLMRealm defaultRealm] withValue:object];
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    return returnObj;
}

-(User *)currentUserFromRealm
{
    return [self userFromCacheWithId:self.currentUser.userId];
    //return [User objectForPrimaryKey:[NSNumber numberWithInteger:self.currentUser.userId]];
}

- (User *)userFromCacheWithId:(NSInteger)userId
{
    return [User objectForPrimaryKey:[NSNumber numberWithInteger:userId]];
    //return [[[self currentUserFromRealm].userCache objectsWhere:@"userId = %@", [NSNumber numberWithInteger:userId]] firstObject];
}

- (void)cacheFriendsData:(NSDictionary *)dictionary
{
    User *currentUser = [self currentUserFromRealm];
    NSArray *friendIds = [dictionary objectForKey:@"friends"];
    NSArray *pendingIds = [dictionary objectForKey:@"pending"];
    NSArray *requestIds = [dictionary objectForKey:@"requests"];
    
    [self handleFriends:friendIds forFriendGroup:FriendGroupFriends ofCurrentUser:currentUser];
    [self handleFriends:pendingIds forFriendGroup:FriendGroupPending ofCurrentUser:currentUser];
    [self handleFriends:requestIds forFriendGroup:FriendGroupRequest ofCurrentUser:currentUser];
}

- (void)handleFriends:(NSArray *)userIds forFriendGroup:(FriendGroup)group ofCurrentUser:(User *)currentUser
{
    for (NSNumber *userId in userIds)
    {
        User *user = [[PostidManager sharedManager] userFromCacheWithId:[userId integerValue]];
        if (!user)
        {
            [self downloadAndAddUser:userId toFriendGroup:group ofCurrentUser:currentUser];
        }
        else
        {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                switch (group) {
                    case FriendGroupFriends:
                        if (![user friendsWithPrimaryUser])
                            [currentUser.friends addObject:user];
                        break;
                    case FriendGroupRequest:
                        if (![user requestedFriendsWithPrimaryUser])
                            [currentUser.requestedFriends addObject:user];
                        break;
                    case FriendGroupPending:
                        if (![user pendingFriendsWithPrimaryUser])
                            [currentUser.pendingFriends addObject:user];
                        break;
                    default:
                        break;
                }
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}

- (void)downloadAndAddUser:(NSNumber *)userId toFriendGroup:(FriendGroup)group ofCurrentUser:(User *)currentUser
{
    [PostidApi downloadUserForId:userId completion:^(BOOL success, User *user) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMRealm defaultRealm] beginWriteTransaction];
                {
                    [User createOrUpdateInDefaultRealmWithValue:user];
                    switch (group) {
                        case FriendGroupFriends:
                            [currentUser.friends addObject:user];
                            break;
                        case FriendGroupRequest:
                            [currentUser.requestedFriends addObject:user];
                            break;
                        case FriendGroupPending:
                            [currentUser.pendingFriends addObject:user];
                            break;
                        default:
                            break;
                    }
                }
                [[RLMRealm defaultRealm] commitWriteTransaction];
            });
        }
    }];
}


@end
