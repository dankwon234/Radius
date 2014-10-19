//
//  MQSubmitApplicationViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQApplication.h"

@interface MQSubmitApplicationViewController : MQViewController <UITextViewDelegate>

@property (strong, nonatomic) MQApplication *application;
@end
