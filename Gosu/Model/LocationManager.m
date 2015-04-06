//
//  LocationManager.m
//  Gosu
//
//  Created by dragon on 4/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LocationManager.h"
#import <Parse/Parse.h>
#import "DataManager.h"
#import "PFUser+Extra.h"

@interface LocationManager()<CLLocationManagerDelegate>


@end

@implementation LocationManager

+ (instancetype)manager
{
    static dispatch_once_t once;
    static LocationManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        
        self.currentLocation = nil;
        
        self.clManager = [[CLLocationManager alloc] init];
        self.clManager.delegate = self;
        
        [self.clManager startMonitoringSignificantLocationChanges];
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        self.currentLocation = newLocation;
        
        if ([PFUser currentUser]) {
            [[DataManager manager] runInBackgroundWithBlock:^{
                PFUser *user = [PFUser currentUser];
                user[kParseUserLocationKey] = [PFGeoPoint geoPointWithLocation:newLocation];
                [user save];
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    DLog(@"Location Manager : %@", error);
}


@end
