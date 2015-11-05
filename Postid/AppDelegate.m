//
//  AppDelegate.m
//  Postid
//
//  Created by Philip Bale on 8/15/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
#import <Realm/Realm.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "User.h"
#import "Post.h"
#import <Realm/RLMRealm.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[CrashlyticsKit, DigitsKit]];
    
    [self handleMigrations];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:51691c48-fcd3-4522-bbdc-dd3846c3d75e"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    //[AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    
    NSLog(@"Realm path %@", [RLMRealm defaultRealmPath]);
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    return YES;
}

- (void)handleMigrations
{
    [RLMRealm setSchemaVersion:5 forRealmAtPath:[RLMRealm defaultRealmPath] withMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        [migration enumerateObjects:User.className
                              block:^(RLMObject *oldUser, RLMObject *newUser) {
                                  if (oldSchemaVersion < 2) {
                                      newUser[@"phoneNumber"] = @"";
                                  }
                                  
                                  if (oldSchemaVersion < 3) {
                                      newUser[@"imageUrl"] = @"";
                                      newUser[@"friends"] = [[RLMArray alloc] initWithObjectClassName:@"User"]
                                      ;
                                      newUser[@"pendingFriends"] = [[RLMArray alloc] initWithObjectClassName:@"User"];
                                      newUser[@"requestedFriends"] = [[RLMArray alloc] initWithObjectClassName:@"User"];
                                  }
                                  
                                  
                              }];
        [migration enumerateObjects:Post.className
                              block:^(RLMObject *oldUser, RLMObject *newUser) {
                                  if (oldSchemaVersion < 4) {
                                      newUser[@"liked"] = @NO;
                                  }
                                  
                                  if (oldSchemaVersion < 5) {
                                      newUser[@"postidForIds"] = [[RLMArray alloc] initWithObjectClassName:@"UserId"];
                                  }
                              }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
