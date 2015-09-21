//
//  AddPostCell.m
//  Postid
//
//  Created by Philip Bale on 9/21/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "AddPostCell.h"

@implementation AddPostCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.showingSelected)
    {
        self.showingSelected = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        self.showingSelected = YES;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    // Configure the view for the selected state
}

@end
