//
//  MQWebViewController.h
//  Listings
//
//  Created by Dan Kwon on 11/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"

@interface MQWebViewController : MQViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString *address;
@end
