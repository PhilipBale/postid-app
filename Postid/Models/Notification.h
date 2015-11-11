//
//  Notification.h
//  Postid
//
//  Created by Philip Bale on 11/10/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Realm/RLMRealm.h>
#import "Realm/RLMObject.h"
#import <Realm/RLMArray.h>

@interface Notification : RLMObject


@property NSInteger notificationId;
@property NSInteger userId;
@property NSInteger fromId;
@property NSString *message;
@property NSInteger postId;
@property NSInteger type;
@property BOOL viewed;
@property NSInteger date; // Unix timestamp

@end

RLM_ARRAY_TYPE(Notification)