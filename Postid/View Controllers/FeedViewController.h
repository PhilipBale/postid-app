//
//  FeedViewController.h
//  Postid
//
//  Created by Philip Bale on 8/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel1;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel2;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel3;


@end
