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
#import <MBProgressHUD/MBProgressHUD.h>

#import "WifiVC.h"
#import "SODAConsumer.h"
#import "SODAQuery.h"
#import "SODAMapAnnotation.h"
#import "SODAMapAnnotationView.h"
#import "SODACallback.h"
#import "SODAResponse.h"
#import "SODAWifi.h"
#import "WifiCell.h"

@implementation WifiVC {
    NSArray *wifiSpots;
    NSMutableDictionary *wifiDict;
    SODAQuery *query;
    SODAResponse *lastResponse;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    MKCoordinateRegion currentUserRegion;
}

@synthesize mapView = _mapView;
@synthesize consumer = _consumer;
@synthesize tableView = _tableView;
@synthesize selectedRow = _selectedRow;


#pragma mark - Initialization Methods

- (id)init {
    self = [super init];
    if (self) {
        
        self.consumer = [SODAConsumer consumerWithDomain:@"data.cityofnewyork.us" token:@" iSWQfAfRYcxK6TC6kiJc9UDqy"];

    }
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    wifiDict = [[NSMutableDictionary alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*35/60)];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];
    
    UIView *spacer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*35/60, self.view.frame.size.width, self.view.frame.size.height*1/60)];
    spacer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:spacer];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*36/60, self.view.frame.size.width, self.view.frame.size.height*24/60)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.title = @"Naked Wifi";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getCurrentLocation:)];
    
    //get initial location
    [self getCurrentLocation:0];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location - defaulting to NYC" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
            
            NSDictionary *addressDictionary =
            placemark.addressDictionary;

            NSString *state = [addressDictionary
                              objectForKey:(NSString *)kABPersonAddressStateKey];
            
            if([state isEqualToString:@"New York"]
               ||
               [state isEqualToString:@"New Jersey"])
            {
                currentUserRegion.center = self.mapView.userLocation.coordinate;
            }
            else
            {
                currentUserRegion.center.latitude = 40.7142;
                currentUserRegion.center.longitude = -74.0064;
            }
            
            currentUserRegion.span.latitudeDelta = .002;
            currentUserRegion.span.longitudeDelta = .002;
            [self.mapView setRegion:currentUserRegion animated:YES];
            
            [self queryData];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

- (IBAction)getCurrentLocation:(id)sender {
    
    //show activity indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;    
    [locationManager startUpdatingLocation];
}

#pragma UITableView delegate
-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return wifiSpots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WifiCell";
    WifiCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[WifiCell class]])
            {
                cell = (WifiCell *)currentObject;
                break;
            }
        }
    }
    
    SODAMapAnnotation *annotation = (SODAMapAnnotation *)[wifiSpots objectAtIndex:indexPath.row];
    
    SODAWifi *wifi = [wifiDict objectForKey:annotation.annotationId];
    
    cell.name.text = wifi.name;
    cell.address.text = [NSString stringWithFormat:@"%@ %@ %@", wifi.address, wifi.city, wifi.zip];
    cell.url.text = wifi.url;
    NSString *imageName = [wifi.type isEqualToString:@"Free"]?@"free.png":@"cost.png";
    [cell.typeImg setImage:[UIImage imageNamed:imageName]];
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SODAMapAnnotation *annotation = (SODAMapAnnotation *)[wifiSpots objectAtIndex:indexPath.row];
    
    if(self.selectedRow && indexPath.row == self.selectedRow.row)
    {
        self.selectedRow = nil;
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    else
    {
        self.selectedRow = indexPath;
        [self.mapView selectAnnotation:annotation animated:YES];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.selectedRow && indexPath.row == self.selectedRow.row) {
        return 100;
    }
    return 32;
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self viewForAnnotation:annotation];
}

- (void)populateDetailTableFromVisibleAnnotations:(MKMapView *)mapView {
    MKMapRect visibleMapRect = mapView.visibleMapRect;
    NSSet *visibleAnnotations = [mapView annotationsInMapRect:visibleMapRect];
    wifiSpots = [visibleAnnotations allObjects];
    [self.tableView reloadData];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    [self populateDetailTableFromVisibleAnnotations:mapView];
    
}

#pragma mark - Query Methods

- (void)queryData {
    
    // Make sure the consumer is initialized
    assert(self.consumer != nil);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        } else {
            // Get the data from the response and create annotations for each one
            NSArray *data = response.entity;
            for (int j = 0; j < data.count; j++) {
                
                //store for later and retrieve from annotation id
                SODAWifi *wifi = [data objectAtIndex:j];
                [wifiDict setObject:wifi forKey:wifi.id];
                
                SODAMapAnnotation *annotation = [self annotationForObject:wifi];
                
                
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
        
        [self populateDetailTableFromVisibleAnnotations:self.mapView];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
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

/**
 * Invoked each time the maps moves around
 */
- (SODAQuery *)queryForMapWithGeoBox:(SODAGeoBox *)geoBox{
    
    query = [[SODAQuery alloc] initWithDataset:@"ehc4-fktp" mapping:[SODAWifi class]];
    
    //[query where:@"zip" startsWith:@"282"];
    
    return query;
}

/**
 * Invoked for each serialized object on a SODA response
 */
- (SODAMapAnnotation *)annotationForObject:(SODAWifi *) wifi {
    
    SODAMapAnnotation *annotation = [SODAMapAnnotation annotationWithObject:wifi atLocation:wifi.location];
    
    annotation.title = wifi.name;
    annotation.annotationId = wifi.id;
    annotation.subtitle = [NSString stringWithFormat:@"%@ - %@", wifi.address, wifi.type];
    
    return annotation;
}
@end