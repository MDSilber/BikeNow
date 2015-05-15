//
//  BikeNowViewController.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowViewController.h"

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
    [self.locationManager startUpdatingLocation];
}

- (void)_showLocationServicesDeniedPrompt
{
    
}

- (void)_fetchLocationAndNearestStation
{
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
}

@end
