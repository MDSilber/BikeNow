//
//  BikeNowViewController.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowViewController.h"

@import CoreLocation;

@interface BikeNowViewController ()
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation BikeNowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    self.locationManager = [CLLocationManager new];

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
            [self _fetchNearestStation];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)_requestLocationPermission
{
    
}

- (void)_showLocationServicesDeniedPrompt
{
    
}

- (void)_fetchNearestStation
{
    
}

@end
