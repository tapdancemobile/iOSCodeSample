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

#import "SODAWifi.h"
#import "SODALocation.h"

/**
 * Model class where SODA Response results get mapped for each one of the matching wifi points
 */
@implementation SODAWifi {
    
}

#pragma mark - Properties

@synthesize phone = _phone;
@synthesize name = _name;
@synthesize address = _address;
@synthesize city = _city;
@synthesize zip = _zip;
@synthesize location = _location;
@synthesize url = _url;
@synthesize type = _type;
@synthesize id = _id;

#pragma mark - SODAPropertyMapping custom mappings impl

/**
 * This custom mapping allows soda response properties to be mapped to object properties with names that do not match those on the
 * remote objects
 */
- (NSDictionary *)propertyMappings {
    return @{
             @"id" : @"id",
             @"shape" : @"location",
             @"name" : @"name",
             @"address" : @"address",
             @"city" : @"city",
             @"zip" : @"zip",
             @"url" : @"url",
             @"type" : @"type"
             };
}


@end