//
//  BikeNowView.h
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

typedef NS_ENUM(NSUInteger, StationPathType) {
    StationPathTypeUnknown,
    StationPathTypeAll,
    StationPathTypeBike,
    StationPathTypeDock
};

@class BikeNowView;

@protocol BikeNowViewDelegate <MKMapViewDelegate>
- (void)bikeNowViewShouldReload:(BikeNowView *)bikeNowView;
- (void)bikeNowView:(BikeNowView *)bikeNowView setPathType:(StationPathType)pathType;
@end

@interface BikeNowView : UIView
@property (nonatomic, weak) id<BikeNowViewDelegate> delegate;
@property (nonatomic, readonly) MKMapView *mapView;

- (void)updateWithStations:(NSArray *)stations;
- (void)updatewithLocation:(CLLocation *)location;
@end
