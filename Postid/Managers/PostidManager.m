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
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImagePrefetcher.h>

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
//    User *oldUser = [User objectForPrimaryKey:[NSNumber numberWithInteger:currentUser.userId]];
//    if (oldUser)
//    {
//        currentUser.friends = oldUser.friends;
//        currentUser.pendingFriends = oldUser.pendingFriends;
//        currentUser.requestedFriends = oldUser.requestedFriends;
//        currentUser.phoneFriends = oldUser.phoneFriends;
//        currentUser.imageUrl = oldUser.imageUrl;
//    }
    
    self.currentUserId = currentUser.userId;
    
    [self expressDefaultRealmWrite:currentUser];
    [self saveTokenToKeychain:currentUser.token];
    [[HTTPManager sharedManager] setRequestHeadersForAPIToken:currentUser.token];
}

- (void)logout
{
    self.currentUser = nil;
    [self saveTokenToKeychain:nil];
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    {
    [[RLMRealm defaultRealm] deleteAllObjects];
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
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

- (void)saveMaxPostIdToKeychain:(NSNumber *)maxPostId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:maxPostId forKey:@"maxPostId"];
    [defaults synchronize];
}

- (NSNumber *)loadMaxPostIdFromKeychain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"maxPostId"];
}

- (void)saveMaxNotificationIdToKeychain:(NSNumber *)maxNotificationId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:maxNotificationId forKey:@"maxNotificationId"];
    [defaults synchronize];
}

- (NSNumber *)loadMaxNotificationIdFromKeychain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"maxNotificationId"];
}

- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object
{
    [[RLMRealm defaultRealm] beginWriteTransaction];
    RLMObject *returnObj = [object.class createOrUpdateInRealm:[RLMRealm defaultRealm] withValue:object];
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    return returnObj;
}

-(User *)currentUser
{
    return [self userFromCacheWithId:self.currentUserId];
    //return [User objectForPrimaryKey:[NSNumber numberWithInteger:self.currentUser.userId]];
}

- (User *)userFromCacheWithId:(NSInteger)userId
{
    return [User objectForPrimaryKey:[NSNumber numberWithInteger:userId]];
    //return [[[self currentUserFromRealm].userCache objectsWhere:@"userId = %@", [NSNumber numberWithInteger:userId]] firstObject];
}

- (Post *)postFromCacheWithId:(NSNumber *)postId
{
    return [Post objectForPrimaryKey:postId];
}

- (Post *)postFromCacheWithIntegerId:(NSInteger)postId
{
    return [self postFromCacheWithId:[NSNumber numberWithInteger:postId]];
}

- (void)cacheFriendsData:(NSDictionary *)dictionary
{
    User *currentUser = [self currentUser];
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
                    case FriendGroupPhone:
                        if (![user phoneFriendsWithPrimaryUser])
                            [currentUser.phoneFriends addObject:user];
                    default:
                        break;
                }
                [User createOrUpdateInDefaultRealmWithValue:user];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
    }
}

- (void)downloadAndAddUser:(NSNumber *)userId toFriendGroup:(FriendGroup)group ofCurrentUser:(User *)currentUser
{
    [PostidApi downloadUserForId:userId completion:^(BOOL success, User *oldUser, User *downloaded) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMRealm defaultRealm] beginWriteTransaction];
                {
                    User *realmDownloadedUser = [User createOrUpdateInDefaultRealmWithValue:downloaded];
                    switch (group) {
                        case FriendGroupFriends:
                            [currentUser.friends addObject:realmDownloadedUser];
                            break;
                        case FriendGroupRequest:
                            [currentUser.requestedFriends addObject:realmDownloadedUser];
                            break;
                        case FriendGroupPending:
                            [currentUser.pendingFriends addObject:realmDownloadedUser];
                            break;
                        case FriendGroupPhone:
                            [currentUser.phoneFriends addObject:realmDownloadedUser];
                        default:
                            break;
                    }
                }
                [[RLMRealm defaultRealm] commitWriteTransaction];
            });
        }
    }];
}

//- (void)cachePosts:(NSArray *)posts
//{
//    User *currentUser = [self currentUser];
//    for (Post *post in posts)
//    {
//        Post* localPost = [self postFromCacheWithIntegerId:post.postId];
//        User* poster = [self userFromCacheWithId:post.userId];
//        [[RLMRealm defaultRealm] beginWriteTransaction];
//        {
//            if (localPost)
//            {
//                [post setLiked:localPost.liked];
//                [post setLikePressed:localPost.likePressed];
//            }
//            
//            [Post createOrUpdateInDefaultRealmWithValue:post];
//        }
//        [[RLMRealm defaultRealm] commitWriteTransaction];
//        
//        if (!poster && post.userId != currentUser.userId)
//        {
//            [PostidApi downloadUserForId:[NSNumber numberWithInteger:post.userId] completion:^(BOOL success, User *currentUser, User *downloaded) {
//                // TODO be careful because we could potential overrite important user data
//                [[PostidManager sharedManager] expressDefaultRealmWrite:downloaded];
//            }];
//        }
//    }
//}

- (void)makePostForUsers:(NSArray *)userIds withImageData:(NSData *)imageData completion:(void (^)(BOOL success))completion
{
    NSLog(@"Attempting to make post");
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    User *user = [self currentUser];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
    [imageData writeToFile:path atomically:YES];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    NSString *imageKey = [NSString stringWithFormat:@"%li/%.0f.jpg", [user userId], ([[NSDate date] timeIntervalSince1970])];
    uploadRequest.bucket = @"postidimages";
    uploadRequest.key = imageKey;
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.body = url;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
        }else{
            if (task.result) {
                AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                [PostidApi makePost:imageKey userIdArray:userIds completion:^(BOOL success) {
                    completion(success);
                }];
                NSLog(@"Image successfully uploaded w/ etag: %@", [uploadOutput ETag]);
            }
        }
        completion(false);
        return nil;
    }];
}

- (void)uploadProfilePhoto:(NSData *)imageData completion:(void (^)(BOOL success, NSString *imageName))completion
{
    NSLog(@"Attempting to upload profile photo");
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
    [imageData writeToFile:path atomically:YES];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    NSString *imageKey = [NSString stringWithFormat:@"profile_photos/%@.jpg", [[NSUUID UUID] UUIDString]];
    uploadRequest.bucket = @"postidimages";
    uploadRequest.key = imageKey;
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.body = url;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
        }else{
            if (task.result) {
                AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                NSLog(@"Image successfully uploaded w/ etag: %@", [uploadOutput ETag]);
                completion(YES, imageKey);
            }
        }
        completion(NO, @"nil");
        return nil;
    }];

}

- (void)cacheNotifications:(NSArray *)notifications
{
    //User *currentUser = [self currentUser];
    for (Notification *notification in notifications)
    {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        {
            [Notification createOrUpdateInDefaultRealmWithValue:notification];
        }
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}

-(void)downloadImage
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    // Construct the NSURL for the download location.
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = @"postidimages";
    downloadRequest.key = @"logo.png";
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error){
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   NSLog(@"Hi");
                                                                   AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   //File downloaded successfully.
                                                               }
                                                               return nil;
                                                           }];
}


@end
