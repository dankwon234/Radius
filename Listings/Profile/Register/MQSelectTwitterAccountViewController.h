//
//  MQSelectTwitterAccountViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/12/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQSocialAccountsMgr.h"

@interface MQSelectTwitterAccountViewController : MQViewController <UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) MQSocialAccountsMgr *socialMgr;
@end
