//
//  SearchCell.h
//  Postid
//
//  Created by Philip Bale on 9/12/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UILabel *userUsername;
@property (weak, nonatomic) IBOutlet UIButton *rightWidget;
@property (nonatomic) NSInteger userId;

@end
