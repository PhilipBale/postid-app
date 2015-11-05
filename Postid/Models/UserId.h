//
//  UserId.h
//  Postid
//
//  Created by Philip Bale on 11/5/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Realm/RLMRealm.h>
#import "Realm/RLMObject.h"
#import <Realm/RLMArray.h>

@interface UserId : RLMObject

@property NSInteger userId;

@end

RLM_ARRAY_TYPE(UserId)