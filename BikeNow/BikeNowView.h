//
//  BikeNowView.h
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@protocol BikeNowViewDelegate <MKMapViewDelegate>
@end

@interface BikeNowView : UIView
@property (nonatomic, weak) id<BikeNowViewDelegate> delegate;
@end
