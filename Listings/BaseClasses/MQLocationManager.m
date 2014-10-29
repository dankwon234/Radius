//
//  MQLocationManager.m
//  Listings
//
//  Created by Dan Kwon on 10/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQLocationManager.h"

@implementation MQLocationManager
@synthesize locationManager;
@synthesize cities;
@synthesize now;
@synthesize geoCoder;
@synthesize currentCity;
@synthesize completion;
@synthesize currentLocation;

- (id)init
{
    self = [super init];
    if (self){
        self.cities = [NSMutableArray array];
    }
    return self;
}

+ (MQLocationManager *)sharedLocationManager
{
    static MQLocationManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MQLocationManager alloc] init];
        
    });
    
    return shared;
}



- (void)findLocation:(MQLocationManagerCompletionBlock)callback
{
    if (callback != NULL)
        self.completion = callback;
    
    if (self.locationManager==nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) // required in iOS 8 and up
        [self.locationManager requestWhenInUseAuthorization];
    
    
    self.now = [[NSDate date] timeIntervalSinceNow];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"manager didUpdateLocations:");
    static double minAccuracy = 3000.0f;
    CLLocation *bestLocation = nil;
    for (CLLocation *location in locations) {
        if (([location.timestamp timeIntervalSince1970]-self.now) < 0) // cached location, ignore
            continue;
        
        
        NSLog(@"LOCATION: %@, %.4f, %4f, ACCURACY: %.2f,%.2f", [location.timestamp description], location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, location.verticalAccuracy);
        
        if (location.horizontalAccuracy <= minAccuracy && location.horizontalAccuracy <= minAccuracy){
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
            bestLocation = location;
            break;
        }
    }
    
    if (bestLocation==nil) // couldn't find location to desired accuracy
        return;
    
    self.currentLocation = bestLocation.coordinate;
    [self reverseGeocode:self.locationManager.location.coordinate completion:^{
        if (self.completion == NULL)
            return;
        
        self.completion(nil);
        self.completion = NULL;
    }];
    
}

- (void)reverseGeocode:(CLLocationCoordinate2D)location completion:(void (^)(void))callback
{
    NSLog(@"reverseGeocode:");
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
                
                if ([self.cities containsObject:cityState]==NO)
                    [self.cities addObject:cityState];
            }
        }
        
        if (callback != nil)
            callback();
        
    }];
    
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    if (self.completion==NULL)
        return;
    
    self.completion(error);
    self.completion = NULL;
}




@end
