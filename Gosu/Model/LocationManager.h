//
//  LocationManager.h
//  Gosu
//
//  Created by dragon on 4/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *clManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (instancetype) manager;
@end
