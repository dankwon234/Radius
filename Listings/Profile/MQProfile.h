//
//  MQProfile.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MQProfile : NSObject

@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *bio;
@property (copy, nonatomic) NSString *password;
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
@property (strong, nonatomic) NSMutableArray *applications;
@property (strong, nonatomic) NSMutableArray *references;
@property (strong, nonatomic) NSMutableArray *saved;
@property (strong, nonatomic) NSMutableArray *searches; // array of city, state of search history
@property (strong, nonatomic) UIImage *imageData;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL populated;
+ (MQProfile *)sharedProfile;
- (void)populate:(NSDictionary *)profileInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)fetchImage;
- (void)updateProfile;
- (NSString *)formattedPhone;
@end
