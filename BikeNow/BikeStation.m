//
//  BikeStation.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeStation.h"

@interface BikeStation ()
@property (nonatomic, readwrite) NSString *addressStreet;
@property (nonatomic, readwrite) NSString *addressCity;
@property (nonatomic, readwrite) NSString *addressState;
@property (nonatomic, readwrite) NSString *addressZipCode;
@property (nonatomic, readwrite) NSUInteger bikesAvailable;
@property (nonatomic, readwrite) NSUInteger docksAvailable;
@property (nonatomic, readwrite) NSString *stationID;
@property (nonatomic, readwrite) NSString *stationName;
@property (nonatomic, readwrite) NSUInteger totalDocks;
@property (nonatomic, readwrite) BOOL inService;
@property (nonatomic, readwrite) StationCity stationCity;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *subtitle;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end

@implementation BikeStation

+ (BikeStation *)stationForJSON:(NSDictionary *)json stationCity:(StationCity)stationCity
{
    return [[self alloc] initWithJSON:json stationCity:stationCity];
}

- (instancetype)initWithJSON:(NSDictionary *)json stationCity:(StationCity)stationCity
{
    self = [super init];
    
    if (self) {
        _stationCity = StationCityPhiladelphia;
        
        if (stationCity == StationCityPhiladelphia) {
            [self _setUpForPhiladelphiaStationWithJSON:json];
        } else {
            [self _setUpForNonPhiladelphiaStationWithJSON:json];
        }
    }
    
    return self;
}

- (NSString *)title
{
    return self.stationName;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%lu bikes, %lu docks", (unsigned long)self.bikesAvailable, (unsigned long)self.docksAvailable];
}

- (void)_setUpForPhiladelphiaStationWithJSON:(NSDictionary *)json
{
    NSArray *coordinates = json[@"geometry"][@"coordinates"];
    if (coordinates) {
        _coordinate = CLLocationCoordinate2DMake([[coordinates firstObject] doubleValue], [[coordinates lastObject] doubleValue]);
    }
    
    NSDictionary *properties = json[@"properties"];
    if (properties) {
        _addressStreet = properties[@"addressStreet"];
        _addressCity = properties[@"addressCity"];
        _addressState = properties[@"addressState"];
        _addressZipCode = properties[@"addressZipCode"];
        _bikesAvailable = [properties[@"bikesAvailable"] integerValue];
        _docksAvailable = [properties[@"docksAvailable"] integerValue];
        _stationID = [properties[@"kioskID"] stringValue];
        _inService = [properties[@"kioskPublicStatus"] isEqualToString:@"Active"];
        _stationName = properties[@"name"];
        _totalDocks = [properties[@"totalDocks"] integerValue];
    }
}

- (void)_setUpForNonPhiladelphiaStationWithJSON:(NSDictionary *)json
{
    _stationID = [json[@"id"] stringValue];
    _stationName = json[@"stationName"];
    _docksAvailable = [json[@"availableDocks"] integerValue];
    _totalDocks = [json[@"totalDocks"] integerValue];
    _coordinate = CLLocationCoordinate2DMake([json[@"latitude"] doubleValue], [json[@"longitude"] doubleValue]);
    _inService = [json[@"statusValue"] isEqualToString:@"In Service"] && ![json[@"testStation"] boolValue];
    _bikesAvailable = [json[@"availableBikes"] integerValue];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[BikeStation class]] && [((BikeStation *)object).stationID isEqualToString:self.stationID];
}

- (NSUInteger)hash
{
    return self.stationID.hash;
}

@end
