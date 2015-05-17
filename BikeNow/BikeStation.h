//
//  BikeStation.h
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, StationCity) {
    StationCityUnknown,
    StationCityNYC,
    StationCityPhiladelphia,
    StationCitySF,
    StationCityChicago
};

@import CoreLocation;
@import MapKit;

@interface BikeStation : NSObject <MKAnnotation>

@property (nonatomic, readonly) NSString *addressStreet;
@property (nonatomic, readonly) NSString *addressCity;
@property (nonatomic, readonly) NSString *addressState;
@property (nonatomic, readonly) NSString *addressZipCode;
@property (nonatomic, readonly) NSUInteger bikesAvailable;
@property (nonatomic, readonly) NSUInteger docksAvailable;
@property (nonatomic, readonly) NSString *stationID;
@property (nonatomic, readonly) NSString *stationName;
@property (nonatomic, readonly) NSUInteger totalDocks;
@property (nonatomic, readonly) BOOL inService;
@property (nonatomic, readonly) StationCity stationCity;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (BikeStation *)stationForJSON:(NSDictionary *)json stationCity:(StationCity)stationCity;

@end
