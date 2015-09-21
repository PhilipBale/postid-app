//
//  PostSelectorViewController.h
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostSelectorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *postViewButton;

@end
