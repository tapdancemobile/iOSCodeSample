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
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>

@class SODAConsumer;
@class SODAQuery;
@class SODAMapAnnotation;
@class SODAMapAnnotationView;
@class SODAGeoBox;


@interface WifiVC : UIViewController<MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) NSIndexPath *selectedRow;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SODAConsumer *consumer;

#pragma mark - "Abstract" Methods

- (SODAQuery *)queryForMapWithGeoBox:(SODAGeoBox *)geoBox;

- (SODAMapAnnotation *)annotationForObject:(id)object;

#pragma mark - Map Annotation View Methods

- (SODAMapAnnotationView *)viewForAnnotation:(SODAMapAnnotation *)annotation;

@end