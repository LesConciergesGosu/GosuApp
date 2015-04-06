//
//  LocationPicker.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class LocationPicker;

@protocol LocationPickerDelegate <NSObject>

- (void)locationPicker:(LocationPicker *)picker didFinishWithResult:(CLLocationCoordinate2D)result;

@end

@interface LocationPicker : UIViewController

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) id<LocationPickerDelegate> delegate;

@property (nonatomic) NSInteger tag;
@property (nonatomic) CLLocationCoordinate2D coordinate;

+ (instancetype)locationPicker;
@end
