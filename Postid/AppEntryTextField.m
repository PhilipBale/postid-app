//
//  AppEntryTextField.m
//  Postid
//
//  Created by Philip Bale on 8/16/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AppEntryTextField.h"

@implementation AppEntryTextField

-(void)awakeFromNib
{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 10);
}

@end
