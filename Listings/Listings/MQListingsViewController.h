//
//  MQListingsViewController.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"

@interface MQListingsViewController : MQViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) MQLocationManager *locationMgr;
@end
