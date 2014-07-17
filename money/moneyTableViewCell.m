//
//  moneyTableViewCell.m
//  money
//
//  Created by Leah Steinberg on 7/17/14.
//  Copyright (c) 2014 LeahSteinberg. All rights reserved.
//

#import "moneyTableViewCell.h"

@implementation moneyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
