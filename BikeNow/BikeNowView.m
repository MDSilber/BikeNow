//
//  BikeNowView.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowView.h"

@interface BikeNowView ()
@property (nonatomic) UIButton *reloadButton;
@property (nonatomic) MKMapView *mapView;
@end

@implementation BikeNowView

- (void)dealloc
{
    self.mapView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadButton addTarget:self action:@selector(_reload:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reloadButton];
        
        _mapView = [MKMapView new];
        [self addSubview:_mapView];
    }
    
    return self;
}

- (void)setDelegate:(id<BikeNowViewDelegate>)delegate
{
    if (![_delegate isEqual:delegate]) {
        _delegate = delegate;
        self.mapView.delegate = delegate;
    }
}

- (void)updateWithStations:(NSArray *)stations location:(CLLocation *)location
{
    self.mapView.centerCoordinate = location.coordinate;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mapView.frame = self.bounds;
}

#pragma mark - Button actions

- (void)_reload:(id)sender
{
    [self.delegate bikeNowViewShouldReload:self];
}

@end
