//
//  ProfileFeedViewController.h
//  Postid
//
//  Created by Philip Bale on 12/17/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileFeedViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end
