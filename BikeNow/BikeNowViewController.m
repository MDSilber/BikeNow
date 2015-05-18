//
//  BikeNowViewController.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "BikeNowViewController.h"
#import "BikeNowView.h"
#import "BikeStation.h"

static NSString *stationNYCURL = @"http://www.citibikenyc.com/stations/json";
static NSString *stationChicagoURL = @"http://www.divvybikes.com/stations/json";
static NSString *stationSFURL = @"http://www.bayareabikeshare.com/stations/json";
static NSString *stationPhillyURL = @"https://api.phila.gov/bike-share-stations/v1";

@import CoreLocation;
@import MapKit;

typedef NS_ENUM(NSUInteger, StationPathType) {
    StationPathTypeUnknown,
    StationPathTypeAll,
    StationPathTypeBike,
    StationPathTypeDock
};

@interface StationDirectionPolyline : NSObject <MKOverlay>
@property (nonatomic) MKPolyline *path;
@property (nonatomic) StationPathType pathType;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) MKMapRect boundingMapRect;
@end

@implementation StationDirectionPolyline

- (CLLocationCoordinate2D)coordinate
{
    return self.path.coordinate;
}

- (MKMapRect)boundingMapRect
{
    return self.path.boundingMapRect;
}

@end

@interface BikeNowViewController () <CLLocationManagerDelegate, BikeNowViewDelegate>
@property (nonatomic) BikeNowView *bikeNowView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (nonatomic) StationCity userCity;
@property (nonatomic) NSArray *bikeStations;
@end

@implementation BikeNowViewController

- (void)dealloc
{
    self.bikeNowView.delegate = nil;
}

- (void)loadView
{
    self.bikeNowView = [BikeNowView new];
    self.bikeNowView.delegate = self;
    self.view = self.bikeNowView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bikeNowView.frame = self.bikeNowView.window.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userCity = StationCityUnknown;
    
    self.requestManager = [AFHTTPRequestOperationManager new];
    self.requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined: {
            [self _requestLocationPermission];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            [self _showLocationServicesDeniedPrompt];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self _fetchLocation];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)_requestLocationPermission
{
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)_showLocationServicesDeniedPrompt
{
    
}

- (void)_fetchLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)_fetchStationsForCity:(StationCity)city
{
    NSString *url = [self _urlForCity:city];
    
    // No city
    if (!url) {
        return;
    } else {
        __weak typeof(self) weakSelf = self;
        [self.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject isKindOfClass:[NSData class]]) {
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
            [weakSelf _handleSuccessfulResponse:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf _handleErrorResponse:error];
        }];
    }
}

- (void)_handleSuccessfulResponse:(NSDictionary *)responseObject
{
    NSMutableArray *stations = [NSMutableArray new];
    NSDictionary *stationJSON;
    
    // Philly
    if (responseObject[@"features"]) {
        stationJSON = responseObject[@"features"];
    } else if (responseObject[@"stationBeanList"]) {
        stationJSON = responseObject[@"stationBeanList"];
    }
    
    for (NSDictionary *station in stationJSON) {
        [stations addObject:[BikeStation stationForJSON:station stationCity:self.userCity]];
    }
    
    self.bikeStations = [stations sortedArrayUsingComparator:^NSComparisonResult(BikeStation *obj1, BikeStation *obj2) {
        return [@([self _distanceBetweenCoordinate:self.locationManager.location.coordinate andCoordinate:obj1.coordinate]) compare:@([self _distanceBetweenCoordinate:self.locationManager.location.coordinate andCoordinate:obj2.coordinate])];
    }];
    
    [self.bikeNowView updateWithStations:self.bikeStations location:self.locationManager.location];
    [self _getDirectionsForClosestStations];
}

- (void)_getDirectionsForClosestStations
{
    int i = 0;
    while (i < [self.bikeStations count] && ((BikeStation *)self.bikeStations[i]).bikesAvailable == 0) { i++; };
    BikeStation *closestBikeStation = self.bikeStations[i];
    
    i = 0;
    while (i < [self.bikeStations count] && ((BikeStation *)self.bikeStations[i]).docksAvailable == 0) { i++; };
    BikeStation *closestDockStation = self.bikeStations[i];
    
    if ([closestBikeStation isEqual:closestDockStation]) {
        [self _getDirectionsToOneStation:closestBikeStation stationType:StationPathTypeAll];
    } else {
        [self _getDirectionsToOneStation:closestBikeStation stationType:StationPathTypeBike];
        [self _getDirectionsToOneStation:closestDockStation stationType:StationPathTypeDock];
    }
}

- (void)_getDirectionsToOneStation:(BikeStation *)bikeStation stationType:(StationPathType)stationType
{
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:bikeStation.coordinate addressDictionary:nil];
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:destination];
    directionsRequest.transportType = MKDirectionsTransportTypeWalking;
    
    __block MKRoute *routeDetails = nil;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            [self _handleErrorResponse:error];
        } else {
            routeDetails = response.routes.lastObject;
            StationDirectionPolyline *polyline = [StationDirectionPolyline new];
            polyline.path = routeDetails.polyline;
            polyline.pathType = stationType;
            [self.bikeNowView.mapView addOverlay:polyline];
        }
    }];
}

- (void)_handleErrorResponse:(NSError *)error
{
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [manager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            [self _showLocationServicesDeniedPrompt];
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userCity = [self _closestCityToCoordinate:manager.location.coordinate];
    [self _fetchStationsForCity:self.userCity];

    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

#pragma mark - BikeNowViewDelegate

- (void)bikeNowViewShouldReload:(BikeNowView *)bikeNowView
{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BikeStation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }

        annotationView.canShowCallout = YES;
        annotationView.annotation = annotation;
        
        return annotationView;
    } else {
        return nil;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[StationDirectionPolyline class]]) {
        StationDirectionPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route.path];

        if (route.pathType == StationPathTypeDock) {
            routeRenderer.strokeColor = [UIColor redColor];
        } else if (route.pathType == StationPathTypeBike) {
            routeRenderer.strokeColor = [UIColor blueColor];
        } else {
            routeRenderer.strokeColor = [UIColor purpleColor];
        }

        routeRenderer.lineWidth = 2.0f;
        return routeRenderer;
    } else {
        return nil;
    }
}

#pragma mark - Helper methods

- (NSString *)_urlForCity:(StationCity)city
{
    switch (city) {
        case StationCityNYC:
            return stationNYCURL;
        case StationCityPhiladelphia:
            return stationPhillyURL;
        case StationCitySF:
            return stationSFURL;
        case StationCityChicago:
            return stationChicagoURL;
        default:
            return nil;
    }
}

- (StationCity)_closestCityToCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSNumber *distanceToNYC = @([self _distanceBetweenCoordinate:coordinate andCoordinate:[self _newYorkCoordinate]]);
    NSNumber *distanceToPhialdelphia = @([self _distanceBetweenCoordinate:coordinate andCoordinate:[self _philadelphiaCoordinate]]);
    NSNumber *distanceToSF = @([self _distanceBetweenCoordinate:coordinate andCoordinate:[self _sanFranciscoCoordinate]]);
    NSNumber *distanceToChicago = @([self _distanceBetweenCoordinate:coordinate andCoordinate:[self _chicagoCoordinate]]);
    
    NSArray *distances = @[distanceToNYC, distanceToPhialdelphia, distanceToSF, distanceToChicago];
    NSNumber *minDistance = [NSNumber numberWithInteger:INT32_MAX];
    
    for (NSNumber *distance in distances) {
        if ([distance doubleValue] < [minDistance doubleValue]) {
            minDistance = distance;
        }
    }
    
    if ([minDistance isEqualToNumber:distanceToNYC]) {
        return StationCityNYC;
    } else if ([minDistance isEqualToNumber:distanceToPhialdelphia]) {
        return StationCityPhiladelphia;
    } else if ([minDistance isEqualToNumber:distanceToSF]) {
        return StationCitySF;
    } else if ([minDistance isEqualToNumber:distanceToChicago]) {
        return StationCityChicago;
    } else {
        return StationCityUnknown;
    }
}

- (double)_distanceBetweenCoordinate:(CLLocationCoordinate2D)firstCoordinate andCoordinate:(CLLocationCoordinate2D)secondCoordinate
{
    return sqrt(pow(firstCoordinate.latitude - secondCoordinate.latitude, 2) + pow(firstCoordinate.longitude - secondCoordinate.longitude, 2));
}

- (CLLocationCoordinate2D)_philadelphiaCoordinate
{
    return CLLocationCoordinate2DMake(39.951713, -75.158306);
}

- (CLLocationCoordinate2D)_newYorkCoordinate
{
    return CLLocationCoordinate2DMake(40.766244, -73.981981);
}

- (CLLocationCoordinate2D)_sanFranciscoCoordinate
{
    return CLLocationCoordinate2DMake(37.776933, -122.416898);
}

- (CLLocationCoordinate2D)_chicagoCoordinate
{
    return CLLocationCoordinate2DMake(41.883584, -87.627984);
}

@end
