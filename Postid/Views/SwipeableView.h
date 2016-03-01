//
//  SwipableView.h
//  Postid
//
//  Created by Philip Bale on 2/23/16.
//  Copyright © 2016 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLSwipeableView.h"
#import "VotingView.h"

@interface SwipeableView : ZLSwipeableView

@property (nonatomic, strong) VotingView *votingView;

@end
