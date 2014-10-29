//
//  MQProfilesViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/27/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"

@interface MQProfilesViewController : MQViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) MQLocationManager *locationMgr;
@end
