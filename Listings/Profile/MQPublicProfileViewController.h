//
//  MQPublicProfileViewController.h
//  Listings
//
//  Created by Dan Kwon on 11/1/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQPublicProfile.h"

@interface MQPublicProfileViewController : MQViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) MQPublicProfile *publicProfile;
@end
