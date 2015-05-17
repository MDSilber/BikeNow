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

@interface BikeNowViewController () <CLLocationManagerDelegate, BikeNowViewDelegate>
@property (nonatomic) BikeNowView *bikeNowView;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (nonatomic) StationCity userCity;
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
            [weakSelf _handleSuccessfulResponse:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf _handleErrorResponse:error];
        }];
    }
}

- (void)_handleSuccessfulResponse:(id)responseObject
{
    
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
    self.currentLocation = [locations lastObject];
    self.userCity = [self _closestCityToCoordinate:self.currentLocation.coordinate];
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
