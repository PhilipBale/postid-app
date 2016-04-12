//
//  SearchCell.m
//  Postid
//
//  Created by Philip Bale on 9/12/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "SearchCell.h"
#import "User.h"
#import <Realm/RLMRealm.h>
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
    User *currentUser = [[PostidManager sharedManager] currentUser];
    
    BOOL requestedFriendsWithPrimaryUser = [self.user requestedFriendsWithPrimaryUser];
    
    if ([self.user pendingFriendsWithPrimaryUser] || [self.user friendsWithPrimaryUser]) {
        NSLog(@"Already pending friends or friends with this user");
        return;
    }
    
    [PostidApi addFriend:self.userId completion:^(BOOL success, BOOL pending, User *user) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMRealm defaultRealm] beginWriteTransaction];
                {
                    self.user = [[PostidManager sharedManager] userFromCacheWithId:self.user.userId];
                    if (requestedFriendsWithPrimaryUser)
                    {
                        //Confirming existing friend request
                        [currentUser.friends addObject:self.user];
                        [self.rightWidget setBackgroundImage:[UIImage imageNamed:@"confirmed"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        //Initiating new friend request
                        [currentUser.pendingFriends addObject:self.user];
                        [self.rightWidget setBackgroundImage:[UIImage imageNamed:@"pending"] forState:UIControlStateNormal];
                    }
                    [User createOrUpdateInDefaultRealmWithValue:currentUser];
                }
                [[RLMRealm defaultRealm] commitWriteTransaction];
            });
        }
    }];
    
    
    
    
}

@end
