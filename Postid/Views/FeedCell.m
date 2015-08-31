//
//  FeedCell.m
//  Postid
//
//  Created by Philip Bale on 8/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell

- (void)awakeFromNib {
    // Initialization code
    self.reportButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.reportButton.layer.borderWidth = 1;
    self.reportButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)reportButtonPressed:(id)sender {
}

@end
