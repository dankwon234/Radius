//
//  MQSubmitIntroViewController.h
//  Listings
//
//  Created by Dan Kwon on 11/8/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQPublicProfile.h"

@interface MQSubmitIntroViewController : MQViewController <UITextViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *introduction;
@property (strong, nonatomic) MQPublicProfile *publicProfile;
@end
