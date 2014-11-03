//
//  MQReferencesViewController.h
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQPublicProfile.h"

@interface MQReferencesViewController : MQViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MQPublicProfile *publicProfile; // can be nil. if nil, use host profile instead
@end
