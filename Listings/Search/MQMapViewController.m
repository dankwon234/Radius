//
//  MQMapViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/11/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQMapViewController.h"

@interface MQMapViewController ()
@property (strong, nonatomic) MQLocationManager *locationMgr;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *btnSearch;
@property (nonatomic) int index;
@end

@implementation MQMapViewController
@synthesize locationMgr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationMgr = [MQLocationManager sharedLocationManager];
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
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.locationMgr.currentLocation, 800, 800)];

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
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barTintColor = kOrange;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"exit.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.7f*imgExit.size.width, 0.7f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];

    UIImage *imgList = [UIImage imageNamed:@"iconList.png"];
    UIButton *btnList = [UIButton buttonWithType:UIButtonTypeCustom];
    btnList.frame = CGRectMake(0.0f, 0.0f, 0.50f*imgList.size.width, 0.50f*imgList.size.height);
    [btnList setBackgroundImage:imgList forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnList];
    
}

- (void)exit:(UIBarButtonItem *)btn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)checkCoordinates
{
    self.index++;

    if (self.index >= 8){
        self.index = 0;
        NSLog(@"LOCATIONS: %@", [self.locationMgr.cities description]);
        [self.loadingIndicator stopLoading];
        
        BOOL updateProfile = NO;
        for (NSString *cityState in self.locationMgr.cities) {
            if ([self.profile.searches containsObject:cityState]==NO){
                [self.profile.searches insertObject:cityState atIndex:0];
                updateProfile = YES;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (updateProfile)
                [self.profile updateProfile];
        }];
        
        return;
    }
    
    for (NSString *cityState in self.locationMgr.cities) {
        if ([self.locationMgr.cities containsObject:cityState]==NO)
            [self.locationMgr.cities addObject:cityState];
    }

    CGFloat delta = 0.025f;
    CGPoint perimeter[9] = {CGPointMake(0, 0), CGPointMake(-delta, delta), CGPointMake(0.0, delta), CGPointMake(delta, delta), CGPointMake(delta, 0), CGPointMake(delta, -delta), CGPointMake(0, -delta), CGPointMake(-delta, -delta), CGPointMake(-delta, 0)};
    

    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    CGPoint point = perimeter[self.index];

    [self.locationMgr reverseGeocode:CLLocationCoordinate2DMake(center.latitude+point.x, center.longitude+point.y) completion:^{
        [self checkCoordinates];
    }];

}

- (void)searchListings:(UIButton *)btn
{
    [self.loadingIndicator startLoading];
    
    [self.locationMgr.cities removeAllObjects];
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    [self.locationMgr.cities removeAllObjects];
    [self.locationMgr reverseGeocode:CLLocationCoordinate2DMake(center.latitude, center.longitude) completion:^{
        [self checkCoordinates];
    }];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
