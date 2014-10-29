//
//  MQMapViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/11/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import <MapKit/MapKit.h>


@interface MQMapViewController : MQViewController <MKMapViewDelegate>

@property (strong, nonatomic) MQLocationManager *locationMgr;
@property (strong, nonatomic) NSMutableArray *locations; // surrounding towns
@end
