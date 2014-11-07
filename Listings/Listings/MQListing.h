//
//  MQListing.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQListing : NSObject


@property (strong, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *formattedDate;
@property (copy, nonatomic) NSString *profile;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *summary;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *image;
@property (strong, nonatomic) UIImage *imageData;
@property (copy, nonatomic) NSString *icon; // image id of venue that posted the listing
@property (strong, nonatomic) UIImage *iconData;

// these will evenutally come from the profile that created the listing:
@property (copy, nonatomic) NSString *venue;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSArray *applications;
@property (copy, nonatomic) NSArray *saved; // id numbers of profiles that saved this listing
+ (MQListing *)listingWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
- (void)fetchIcon;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
