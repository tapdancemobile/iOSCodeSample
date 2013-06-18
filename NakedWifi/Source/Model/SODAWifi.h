//
//  Naked Wifi
//
//  Copyright (C) 2013 Naked Apartments
//  All rights reserved.
//
//  Developed for Naked Apartments by:
//  Mark Mathis
//  http://tadamobile.com
//  markmathis@gmail.com
//

#import <Foundation/Foundation.h>
#import "SODAPropertyMapping.h"

@class SODALocation;

/**
 * Model class where SODA Response results get mapped for each one of the matching wifi points
 */
@interface SODAWifi : NSObject<SODAPropertyMapping> {
    
    NSString *_id;
    NSString *_phone;
    NSString *_zip;
    NSString *_address;
    NSString *_name;
    NSString *_type;
    NSString *_url;
    NSString *_city;
    SODALocation *_location;
}

#pragma mark - Properties

@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *phone;
@property(nonatomic, copy) NSString *zip;
@property(nonatomic, copy) NSString *address;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, strong) SODALocation *location;


@end