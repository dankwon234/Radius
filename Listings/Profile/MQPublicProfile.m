//
//  MQPublicProfile.m
//  Listings
//
//  Created by Dan Kwon on 10/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQPublicProfile.h"
#import "MQWebServices.h"

@interface MQPublicProfile ()
@property (nonatomic) BOOL fetchingImage;
@end

@implementation MQPublicProfile
@synthesize uniqueId;
@synthesize firstName;
@synthesize lastName;
@synthesize city;
@synthesize state;
@synthesize image;
@synthesize imageData;
@synthesize facebookId;
@synthesize twitterId;
@synthesize linkedinId;
@synthesize schools;
@synthesize bio;
@synthesize skills;
@synthesize resume;
@synthesize video;
@synthesize references;


- (id)init
{
    self = [super init];
    if (self){
        self.fetchingImage = NO;
        self.uniqueId = @"none";
        self.firstName = @"none";
        self.lastName = @"none";
        self.city = @"none";
        self.state = @"none";
        self.image = @"none";
        self.facebookId = @"none";
        self.twitterId = @"none";
        self.linkedinId = @"none";
        self.bio = @"none";
        self.resume = @"none";
        self.video = @"none";
        self.schools = [NSMutableArray array];
        self.skills = [NSMutableArray array];
        self.references = nil;
    }
    
    return self;
}

+ (MQPublicProfile *)publicProfileWithInfo:(NSDictionary *)info
{
    MQPublicProfile *profile = [[MQPublicProfile alloc] init];
    [profile populate:info];
    return profile;
}


- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = [profileInfo objectForKey:@"id"];
    self.firstName = [profileInfo objectForKey:@"firstName"];
    self.lastName = [profileInfo objectForKey:@"lastName"];
    self.city = [profileInfo objectForKey:@"city"];
    self.state = [profileInfo objectForKey:@"state"];
    self.image = [profileInfo objectForKey:@"image"];
    self.facebookId = [profileInfo objectForKey:@"facebookId"];
    self.twitterId = [profileInfo objectForKey:@"twitterId"];
    self.linkedinId = [profileInfo objectForKey:@"linkedinId"];
    self.bio = [profileInfo objectForKey:@"bio"];
    self.resume = [profileInfo objectForKey:@"resume"];
    self.video = [profileInfo objectForKey:@"video"];
    self.skills = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"skills"]];
    self.schools = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"schools"]];
}

- (void)fetchImage
{
    if ([self.image isEqualToString:@"none"])
        return;

    if (self.fetchingImage)
        return;
    
    self.fetchingImage = YES;
    [[MQWebServices sharedInstance] fetchImage:self.image completionBlock:^(id result, NSError *error){
        self.fetchingImage = NO;
        
        if (error)
            return;
        
        self.imageData = (UIImage *)result;
    }];
}









@end
