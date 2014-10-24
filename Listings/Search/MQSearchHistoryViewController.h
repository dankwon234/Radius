//
//  MQSearchHistoryViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/23/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"

@interface MQSearchHistoryViewController : MQViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *locations;
@end
