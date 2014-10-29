//
//  MQLocationManager.h
//  Listings
//
//  Created by Dan Kwon on 10/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^MQLocationManagerCompletionBlock)(NSError *error);


@interface MQLocationManager : NSObject <CLLocationManagerDelegate>

@property (copy, nonatomic) NSString *currentCity;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *cities;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MQLocationManagerCompletionBlock completion;
@property (nonatomic) NSTimeInterval now;
+ (MQLocationManager *)sharedLocationManager;
- (void)findLocation:(MQLocationManagerCompletionBlock)callback;
- (void)reverseGeocode:(CLLocationCoordinate2D)location completion:(void (^)(void))callback;
@end
