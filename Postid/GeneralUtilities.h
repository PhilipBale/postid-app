//
//  GeneralUtilities.h
//  Postid
//
//  Created by Philip Bale on 8/24/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/RLMRealm.h>
#import <Realm/RLMResults.h>

@interface GeneralUtilities : NSObject
 
+ (void)animateView:(UIView *)view up:(BOOL)up delta:(CGFloat)delta duration:(NSTimeInterval)duration;
+ (void)makeAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;
+ (NSMutableArray *) mutableArrayFromRealmResults:(RLMResults *)results;

@end
