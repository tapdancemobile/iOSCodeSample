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

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

#import "WifiVC.h"
#import "SODAConsumer.h"
#import "SODAQuery.h"
#import "SODAMapAnnotation.h"
#import "SODAMapAnnotationView.h"
#import "SODACallback.h"
#import "SODAResponse.h"
#import "SODAWifi.h"

@implementation WifiVC {
    SODAQuery *query;
    SODAResponse *lastResponse;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@synthesize mapView = _mapView;
@synthesize consumer = _consumer;
@synthesize tableView = _tableView;


#pragma mark - Initialization Methods

- (id)init {
    self = [super init];
    if (self) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*1/3)];
        [self.mapView setShowsUserLocation:YES];
        [self.mapView setDelegate:self];
        [self.view addSubview:self.mapView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*1/3, self.view.frame.size.width, self.view.frame.size.height*2/3)];
        [self.tableView setDelegate:self];
        [self.view addSubview:self.tableView];
        
        self.navigationItem.title = @"Naked Wifi";        
        self.consumer = [SODAConsumer consumerWithDomain:@"data.cityofnewyork.us" token:@" iSWQfAfRYcxK6TC6kiJc9UDqy"];

    }
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    locationManager = [[CLLocationManager alloc] init];
    [self getCurrentLocation:0];
    geocoder = [[CLGeocoder alloc] init];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location - defaulting to NYC" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            MKCoordinateRegion region;
            
            NSDictionary *addressDictionary =
            placemark.addressDictionary;

            NSString *state = [addressDictionary
                              objectForKey:(NSString *)kABPersonAddressStateKey];
            
            if([state isEqualToString:@"New York"]
               ||
               [state isEqualToString:@"New Jersey"])
            {
                region.center = self.mapView.userLocation.coordinate;
            }
            else
            {
                region.center.latitude = 40.7142;
                region.center.longitude = -74.0064;
            }
            
            region.span.latitudeDelta = .05;
            region.span.longitudeDelta = .05;
            [self.mapView setRegion:region animated:YES];
            
            [self queryData];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

- (IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;    
    [locationManager startUpdatingLocation];
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    // The map has moved, fetch new data
    [self queryData];
    
}

#pragma mark - Query Methods

- (void)queryData {
    
    // Make sure the consumer is initialized
    assert(self.consumer != nil);
    
    // Get the bounds of the mapview
    CGPoint nePoint = CGPointMake(self.mapView.bounds.origin.x + self.mapView.bounds.size.width, self.mapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake((self.mapView.bounds.origin.x), (self.mapView.bounds.origin.y + self.mapView.bounds.size.height));
    
    CLLocationCoordinate2D neCoord = [self.mapView convertPoint:nePoint toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D swCoord = [self.mapView convertPoint:swPoint toCoordinateFromView:self.mapView];
    
    SODAGeoBox *geoBox = [SODAGeoBox boxWithNorthEastCoordinate:neCoord southWestCoordinate:swCoord];
    
    // Get the query from the subclass
    query = [self queryForMapWithGeoBox:geoBox];
    
    // Call the consumer with the query
    [self.consumer getObjectsForTypedQuery:query result:[SODACallback callbackWithResult:^(SODAResponse *response) {
        
        lastResponse = response;
        
        // Check for errors
        if(response.error) {
            
            // TODO: How should we alert the user of errors? or should we provide a way for the caller to handle them?
            
        } else {
            // Get the data from the response and create annotations for each one
            NSArray *data = response.entity;
            for (int j = 0; j < data.count; j++) {
                SODAMapAnnotation *annotation = [self annotationForObject:[data objectAtIndex:j]];
                if(annotation != nil) {
                    
                    // Make sure we haven't already added this annotation to the map
                    NSUInteger index = [self.mapView.annotations indexOfObjectPassingTest:
                                        ^BOOL(SODAMapAnnotation *otherAnnotation, NSUInteger index, BOOL *stop) {
                                            return (annotation.coordinate.latitude == otherAnnotation.coordinate.latitude &&
                                                    annotation.coordinate.longitude == otherAnnotation.coordinate.longitude);
                                        }];
                    if (index == NSNotFound) {
                        [self.mapView addAnnotation:annotation];
                    }
                    
                    
                }
                
            }
            
            
        }
        
    }]];
}

#pragma mark - Map Annotation View Methods

/**
 * Override this method to create your own annotation view
 */
- (SODAMapAnnotationView *)viewForAnnotation:(SODAMapAnnotation *)annotation {
    
    static NSString *ident = @"SODAMapAnnotationViewPin";
    
    // Just use the default SODAMapAnnotationView, you can subclass it and use your own if you desire
    SODAMapAnnotationView * annotationView = (SODAMapAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:ident];
    if (annotationView == nil) {
        annotationView = [[SODAMapAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:ident];
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
}


#pragma mark - "Abstract" Methods

/**
 * Invoked each time the maps moves around
 */
- (SODAQuery *)queryForMapWithGeoBox:(SODAGeoBox *)geoBox{
    
    SODAQuery *query = [[SODAQuery alloc] initWithDataset:@"ehc4-fktp" mapping:[SODAWifi class]];
    
    //[query where:@"zip" startsWith:@"282"];
    
    return query;
}

/**
 * Invoked for each serialized object on a SODA response
 */
- (SODAMapAnnotation *)annotationForObject:(SODAWifi *) wifi {
    
    SODAMapAnnotation *annotation = [SODAMapAnnotation annotationWithObject:wifi atLocation:wifi.location];
    annotation.title = wifi.name;
    annotation.subtitle = [NSString stringWithFormat:@"Type: %@, Address: %@", wifi.type, wifi.address];
    
    return annotation;
}
@end