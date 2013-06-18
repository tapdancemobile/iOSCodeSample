//
//  WifiCell.m
//  NakedWifi
//
//  Created by ttefabbob on 6/18/13.
//  Copyright (c) 2013 Naked Apartments. All rights reserved.
//

#import "WifiCell.h"

@implementation WifiCell

@synthesize name, address, url, typeImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
