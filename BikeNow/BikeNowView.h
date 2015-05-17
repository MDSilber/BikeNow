//
//  BikeNowView.h
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@class BikeNowView;

@protocol BikeNowViewDelegate <MKMapViewDelegate>
- (void)bikeNowViewShouldReload:(BikeNowView *)bikeNowView;
@end

@interface BikeNowView : UIView
@property (nonatomic, weak) id<BikeNowViewDelegate> delegate;
@property (nonatomic, readonly) MKMapView *mapView;

- (void)updateWithStations:(NSArray *)stations location:(CLLocation *)location;
@end
