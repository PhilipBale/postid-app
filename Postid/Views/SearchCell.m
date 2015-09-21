//
//  SearchCell.m
//  Postid
//
//  Created by Philip Bale on 9/12/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "SearchCell.h"
#import "User.h"
#import "Realm.h"
#import "PostidManager.h"
#import "PostidApi.h"

@implementation SearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.width / 2;
    // Configure the view for the selected state
}

- (IBAction)rightWidgetButtonPressed:(id)sender {
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    User *toAdd = [[PostidManager sharedManager] userFromCacheWithId:self.userId];
    
    
    if ([toAdd pendingFriendsWithPrimaryUser] || [toAdd friendsWithPrimaryUser]) {
        NSLog(@"Already pending friends or friends with this user");
        return;
    }
    
    [PostidApi addFriend:self.userId completion:^(BOOL success, BOOL pending, User *user) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMRealm defaultRealm] beginWriteTransaction];
                {
                    if (pending)
                    {
                        [currentUser.pendingFriends addObject:toAdd];
                        [self.rightWidget setTitle:@"Pending" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [currentUser.friends addObject:toAdd];
                        [self.rightWidget setTitle:@"" forState:UIControlStateNormal];
                    }
                    [User createOrUpdateInDefaultRealmWithValue:currentUser];
                }
                [[RLMRealm defaultRealm] commitWriteTransaction];
                
                [self.rightWidget setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            });
        }
    }];
    
    
    
    
}

@end
