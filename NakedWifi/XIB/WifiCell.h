//
//  WifiCell.h
//  NakedWifi
//
//  Created by ttefabbob on 6/18/13.
//  Copyright (c) 2013 Naked Apartments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WifiCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *url;
@property (nonatomic, strong) IBOutlet UIImageView *typeImg;

@end
