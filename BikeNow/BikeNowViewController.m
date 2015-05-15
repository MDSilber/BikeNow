//
//  BikeNowViewController.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowViewController.h"

static NSString *stationNYCURL = @"http://www.citibikenyc.com/stations/json";
static NSString *stationChicagoURL = @"http://www.divvybikes.com/stations/json";
static NSString *stationSFURL = @"http://www.bayareabikeshare.com/stations/json";
static NSString *stationPhillyURL = @"https://api.phila.gov/bike-share-stations/v1";

@import CoreLocation;
@import MapKit;

@interface BikeNowViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation BikeNowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
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
            [self _fetchLocationAndNearestStation];
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

- (void)_fetchLocationAndNearestStation
{
    [self.locationManager startUpdatingLocation];
    
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
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

@end
