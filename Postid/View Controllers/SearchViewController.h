//
//  SearchViewController.h
//  Postid
//
//  Created by Philip Bale on 8/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DigitsKit/DigitsKit.h>
#import "FriendSearchController.h"

@interface SearchViewController : UIViewController<UISearchBarDelegate, UITextFieldDelegate>

@property (strong, nonatomic) FriendSearchController *searchController;
@property (strong, nonatomic) DGTAuthenticateButton *authenticateButton;

@property (strong, nonatomic) IBOutlet UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneAuthViewHeight;
@property (weak, nonatomic) IBOutlet UIView *phoneAuthView;

@end
