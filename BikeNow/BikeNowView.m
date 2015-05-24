//
//  BikeNowView.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowView.h"

@interface BikeNowView ()
@property (nonatomic) UIView *buttonPanel;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) UIButton *reloadButton;
@property (nonatomic, readwrite) MKMapView *mapView;
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
        
        _mapView = [MKMapView new];
        _mapView.showsUserLocation = YES;
        _mapView.showsPointsOfInterest = NO;
        [self addSubview:_mapView];

        _buttonPanel = [UIView new];
        _buttonPanel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_buttonPanel];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Bike", @"Dock"]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(_segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_buttonPanel addSubview:_segmentedControl];
        
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadButton setImage:[UIImage imageNamed:@"reload_button"] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(_reload:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonPanel addSubview:_reloadButton];
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

- (void)updateWithStations:(NSArray *)stations
{
    for (id<MKAnnotation> annotation in stations) {
        [self.mapView addAnnotation:annotation];
    }
}

- (void)updatewithLocation:(CLLocation *)location
{
    self.mapView.centerCoordinate = location.coordinate;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonPanel.frame = CGRectMake(0.0, 20.0, CGRectGetWidth(self.bounds), 44.0f);
    
    self.segmentedControl.frame = CGRectMake(8.0f, floorf((CGRectGetHeight(self.buttonPanel.bounds) - CGRectGetHeight(self.segmentedControl.bounds))/2.0f), CGRectGetWidth(self.segmentedControl.bounds), CGRectGetHeight(self.segmentedControl.bounds));
    self.reloadButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 48.0f, 6.0f, 32.0f, 32.0f);
    
    self.mapView.frame = self.bounds;
}

#pragma mark - Button actions

- (void)_segmentedControlValueChanged:(UISegmentedControl *)sender
{
    StationPathType pathType = StationPathTypeUnknown;
    switch (sender.selectedSegmentIndex) {
        case 0:
            pathType = StationPathTypeBike;
            break;
        case 1:
            pathType = StationPathTypeDock;
            break;
        default:
            break;
    }
    
    [self.delegate bikeNowView:self setPathType:pathType];
}

- (void)_reload:(id)sender
{
    [self.delegate bikeNowViewShouldReload:self];
}

@end
