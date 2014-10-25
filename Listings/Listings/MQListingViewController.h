//
//  MQListingViewController.h
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQListing.h"

@interface MQListingViewController : MQViewController <UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) MQListing *listing;
@end
