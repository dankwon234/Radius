//
//  MQMapViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/11/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQMapViewController.h"

@interface MQMapViewController ()
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) UIButton *btnSearch;
@property (nonatomic) int index;
@end

@implementation MQMapViewController
@synthesize locations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Select Location";
        self.index = 0;
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    CGFloat height = frame.size.height+kNavBarHeight;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, height)];
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.profile.currentLocation, 800, 800)];
    
    adjustedRegion.span.longitudeDelta  = 0.05f;
    adjustedRegion.span.latitudeDelta  = 0.05f;
    [self.mapView setRegion:adjustedRegion animated:YES];
    [view addSubview:self.mapView];
    
    UIView *search = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    search.backgroundColor = [UIColor grayColor];
    search.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSearch.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
    self.btnSearch.backgroundColor = [UIColor clearColor];
    self.btnSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnSearch.layer.borderWidth = 1.5f;
    self.btnSearch.layer.cornerRadius = 4.0f;
    self.btnSearch.layer.masksToBounds = YES;
    self.btnSearch.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [self.btnSearch setTitle:@"SEARCH" forState:UIControlStateNormal];
    [self.btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSearch addTarget:self action:@selector(searchListings:) forControlEvents:UIControlEventTouchUpInside];
    [search addSubview:self.btnSearch];
    
    [view addSubview:search];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *navBarAttributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f]};
    [self.navigationController.navigationBar setTitleTextAttributes:navBarAttributes];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(exit:)];
    
}

- (void)exit:(UIBarButtonItem *)btn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reverseGeocode:(CLLocationCoordinate2D)location completion:(void (^)(void))completion
{
    if (self.geoCoder==nil)
        self.geoCoder = [[CLGeocoder alloc] init];

    CLLocation *loc = [[CLLocation alloc] initWithCoordinate:location
                                                    altitude:0
                                          horizontalAccuracy:0
                                            verticalAccuracy:0
                                                      course:0
                                                       speed:0
                                                   timestamp:[NSDate date]];
    
    [self.geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) { // Getting Human readable Address from Lat long...
        
        if (placemarks.count > 0){
            BOOL needsUpdate = NO;
            for (CLPlacemark *placeMark in placemarks) {
                NSDictionary *locationInfo = placeMark.addressDictionary;
                NSString *cityState = @"";
                BOOL validLocation = NO;
                
                NSString *city = locationInfo[@"City"];
                NSString *state = locationInfo[@"State"];
                
                if (city!=nil && state!=nil){
                    cityState = [cityState stringByAppendingString:[city lowercaseString]];
                    cityState = [cityState stringByAppendingString:[NSString stringWithFormat:@", %@", [state lowercaseString]]];
                    validLocation = YES;
                }
                
                if (!validLocation)
                    continue;
                
                if ([self.locations containsObject:cityState]==NO)
                    [self.locations addObject:cityState];
                
                if ([self.profile.searches containsObject:cityState]==NO){
                    [self.profile.searches insertObject:cityState atIndex:0];
                    needsUpdate = YES;
                }
            }
            
            if (needsUpdate)
                [self.profile updateProfile];
            
            
        }
        
        if (completion != nil)
            completion();
        
    }];
    
}

- (void)checkCoordinates
{
//    NSLog(@"checkCoordinates");
    self.index++;

    if (self.index >= 8){
        self.index = 0;
        NSLog(@"LOCATIONS: %@", [self.locations description]);
        [self.loadingIndicator stopLoading];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];

        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
        return;
    }

    CGFloat delta = 0.025f;
    CGPoint perimeter[9] = {CGPointMake(0, 0), CGPointMake(-delta, delta), CGPointMake(0.0, delta), CGPointMake(delta, delta), CGPointMake(delta, 0), CGPointMake(delta, -delta), CGPointMake(0, -delta), CGPointMake(-delta, -delta), CGPointMake(-delta, 0)};
    

    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    CGPoint point = perimeter[self.index];

    [self reverseGeocode:CLLocationCoordinate2DMake(center.latitude+point.x, center.longitude+point.y) completion:^{
        [self checkCoordinates];
    }];
}

- (void)searchListings:(UIButton *)btn
{
//    NSLog(@"searchListings: ");
    [self.loadingIndicator startLoading];
    
    [self.locations removeAllObjects];
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    [self reverseGeocode:CLLocationCoordinate2DMake(center.latitude, center.longitude) completion:^{
        [self checkCoordinates];
    }];
    
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
