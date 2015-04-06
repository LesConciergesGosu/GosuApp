//
//  LocationManager.m
//  Gosu
//
//  Created by dragon on 4/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

#import "PFUser+Extra.h"
#import "DataManager.h"

NSString * const kCityDidChangeNotificationKey = @"locationManagerCityDidChange";

@interface LocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLPlacemark *currentPlace;
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
        self.currentCity = nil;
        
//        [self checkAuthorizationStatus];
        
        self.clManager = [[CLLocationManager alloc] init];
        self.clManager.delegate = self;
        
#ifdef __IPHONE_8_0
        if ([self.clManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.clManager requestAlwaysAuthorization];
        }
#endif
        
        [self.clManager startMonitoringSignificantLocationChanges];
    }
    
    return self;
}

#ifdef __IPHONE_8_0
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    BOOL enabled = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            enabled = YES;
        }
    }
    else if (status == kCLAuthorizationStatusAuthorized)
        enabled = YES;
    
    if (enabled)
    {
        [self.clManager stopMonitoringSignificantLocationChanges];
        [self.clManager startMonitoringSignificantLocationChanges];
    }
}
#endif

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        
#if DEBUG
        self.currentLocation =[[CLLocation alloc] initWithLatitude:40.71427 longitude:-74.00597];
#else
        self.currentLocation = newLocation;
#endif
        
//        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//        [geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//            
//            if ([placemarks count] > 0)
//            {
//                self.currentPlace = placemarks[0];
//                self.currentCity = self.currentPlace.locality;
//                [[NSNotificationCenter defaultCenter] postNotificationName:kCityDidChangeNotificationKey object:nil];
//            }
//            else if (error)
//            {
//                [self useGGeocder];
//            }
//        }];
        
        [self useGGeocder];
        
        if ([PFUser currentUser]) {
            [[DataManager manager] runInBackgroundWithBlock:^{
                PFUser *user = [PFUser currentUser];
                user[kParseUserLocationKey] = [PFGeoPoint geoPointWithLocation:newLocation];
                [user save];
            }];
        }
    }
}

- (void)useGGeocder
{
    
    CLLocationCoordinate2D coordinate = self.currentLocation.coordinate;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        
        NSString *path = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&result_type=locality&key=AIzaSyB8s_GRw7iARYfvvJnZlnFV2dpd8i4Z2FU", coordinate.latitude, coordinate.longitude];
        NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSError *error = nil;
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (data)
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (error)
                DLog(@"geocode error : %@", error);
            
            NSArray *results = result[@"results"];
            if ([results count] < 1)
                return;
            
            NSDictionary *address = results[0];
            NSArray *components = address[@"address_components"];
            
            if ([components count] > 0)
            {
                NSString *city = [components[0] objectForKey:@"long_name"];
                
                if (city)
                {
                    self.currentCity = city;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kCityDidChangeNotificationKey object:nil];
                    });
                }
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    DLog(@"Location Manager : %@", error);
}

- (void) checkAuthorizationStatus
{
    
#ifdef __IPHONE_8_0
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            DLog(@"User has not yet made a choice with regards to this application");
            break;
            
        case kCLAuthorizationStatusRestricted:
            DLog(@"This application is not authorized to use location services.  Due to active restrictions on location services, the user cannot change this status, and may not have personally denied authorization");
            break;
            
        case kCLAuthorizationStatusDenied:
            DLog(@"User has explicitly denied authorization for this application, or location services are disabled in Settings.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            DLog(@"User has granted authorization to use their location at any time, including monitoring for regions, visits, or significant location changes.");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            DLog(@"User has granted authorization to use their location only when your app is visible to them (it will be made visible to them if you continue to receive location updates while in the background).  Authorization to use launch APIs has not been granted.");
            break;
        default:
            break;
    }
#endif
    
}


@end
