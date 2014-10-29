//
//  MQPublicProfile.h
//  Listings
//
//  Created by Dan Kwon on 10/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQPublicProfile : NSObject

@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *bio;
@property (copy, nonatomic) NSString *facebookId;
@property (copy, nonatomic) NSString *twitterId;
@property (copy, nonatomic) NSString *linkedinId;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *resume;
@property (copy, nonatomic) NSString *video;
@property (strong, nonatomic) NSMutableArray *schools;
@property (strong, nonatomic) NSMutableArray *skills;
@property (strong, nonatomic) UIImage *imageData;
- (void)populate:(NSDictionary *)profileInfo;
@end
