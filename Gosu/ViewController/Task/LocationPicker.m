//
//  LocationPicker.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LocationPicker.h"
#import "LocationManager.h"
#import "UIViewController+ViewDeck.h"

@interface PickerAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end

@implementation PickerAnnotation

- (NSString *)subtitle{
    return nil;
}

- (NSString *)title{
    return nil;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    coordinate = coord;
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end

@interface LocationPicker () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation LocationPicker

+ (instancetype)locationPicker
{
    LocationPicker *locationPicker = [[LocationPicker alloc] initWithNibName:@"LocationPicker" bundle:nil];
    return locationPicker;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"PICK LOCATION";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.coordinate.longitude == 0 && self.coordinate.latitude == 0)
    {
        if ([LocationManager manager].currentLocation != nil)
            self.coordinate = [LocationManager manager].currentLocation.coordinate;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(self.coordinate, MKCoordinateSpanMake(.2, .2));
    [self.mapView setRegion:region];
    
    PickerAnnotation *annotation = [[PickerAnnotation alloc] initWithCoordinate:self.coordinate];
    [self.mapView addAnnotation:annotation];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController deckController])
        [[self.navigationController deckController] setPanningGestureDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController deckController] && [self.navigationController deckController].panningGestureDelegate == self)
        [[self.navigationController deckController] setPanningGestureDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(locationPicker:didFinishWithResult:)])
    {
        [self.delegate locationPicker:self didFinishWithResult:self.coordinate];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Side Menu Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner
{
    return NO;
}

#pragma mark MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[PickerAnnotation class]])
    {
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PickerPin"];
        
        if (!pin)
        {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PickerPin"];
        }
        else
        {
            pin.annotation = annotation;
        }
        
        pin.animatesDrop = YES;
        pin.draggable = YES;
        
        return pin;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling)
    {
        self.coordinate = view.annotation.coordinate;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
