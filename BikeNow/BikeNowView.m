//
//  BikeNowView.m
//  BikeNow
//
//  Created by Mason Silber on 5/15/15.
//  Copyright (c) 2015 Mason Silber. All rights reserved.
//

#import "BikeNowView.h"

@implementation BikeNowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
