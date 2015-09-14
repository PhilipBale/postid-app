//
//  PostidManager.m
//  Postid
//
//  Created by Philip Bale on 8/22/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "PostidManager.h"
#import "HTTPManager.h"
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
    return [User objectForPrimaryKey:[NSNumber numberWithInteger:self.currentUser.userId]];
}

- (User *)userFromCacheWithId:(NSInteger)userId
{
    return [[[self currentUserFromRealm].userCache objectsWhere:@"userId = %@", [NSNumber numberWithInteger:userId]] firstObject];
}


@end
