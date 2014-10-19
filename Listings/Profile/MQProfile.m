//
//  MQProfile.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQProfile.h"
#import "MQWebServices.h"

@implementation MQProfile
@synthesize uniqueId;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize password;
@synthesize city;
@synthesize state;
@synthesize image;
@synthesize imageData;
@synthesize currentLocation;
@synthesize facebookId;
@synthesize twitterId;
@synthesize linkedinId;
@synthesize schools;
@synthesize bio;
@synthesize phone;
@synthesize skills;
@synthesize populated;
@synthesize applications;
@synthesize resume;
@synthesize video;

- (id)init
{
    self = [super init];
    if (self){
        self.currentLocation = CLLocationCoordinate2DMake(0.0f, 0.0f);
        self.uniqueId = @"none";
        self.firstName = @"none";
        self.lastName = @"none";
        self.email = @"none";
        self.city = @"none";
        self.state = @"none";
        self.image = @"none";
        self.facebookId = @"none";
        self.twitterId = @"none";
        self.linkedinId = @"none";
        self.phone = @"none";
        self.bio = @"none";
        self.resume = @"none";
        self.video = @"none";
        self.schools = [NSMutableArray array];
        self.skills = [NSMutableArray array];
        self.applications = [NSMutableArray array];
        self.populated = NO;

        [self populateFromCache];
        
        if ([self.uniqueId isEqualToString:@"none"]==NO)
            [self refreshProfileInfo];

    }
    return self;
}



+ (MQProfile *)sharedProfile
{
    static MQProfile *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MQProfile alloc] init];
        
    });
    
    return shared;
}

- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = [profileInfo objectForKey:@"id"];
    self.firstName = [profileInfo objectForKey:@"firstName"];
    self.lastName = [profileInfo objectForKey:@"lastName"];
    self.email = [profileInfo objectForKey:@"email"];
    self.city = [profileInfo objectForKey:@"city"];
    self.state = [profileInfo objectForKey:@"state"];
    self.image = [profileInfo objectForKey:@"image"];
    self.facebookId = [profileInfo objectForKey:@"facebookId"];
    self.twitterId = [profileInfo objectForKey:@"twitterId"];
    self.linkedinId = [profileInfo objectForKey:@"linkedinId"];
    self.bio = [profileInfo objectForKey:@"bio"];
    self.phone = [profileInfo objectForKey:@"phone"];
    self.resume = [profileInfo objectForKey:@"resume"];
    self.video = [profileInfo objectForKey:@"video"];
    self.skills = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"skills"]];
    self.schools = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"schools"]];
    self.applications = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"applications"]];
    self.populated = YES;
    
    [self cacheProfile];
}


- (void)cacheProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"user"];
    [defaults synchronize];
}



- (void)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"user"];
    if (!json)
        return;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"STORED PROFILE: %@", [profileInfo description]);
    
    if (error)
        return;
    
    [self populate:profileInfo];
}



- (void)fetchImage
{
    if ([self.image isEqualToString:@"none"])
        return;
    
    [[MQWebServices sharedInstance] fetchImage:self.image completionBlock:^(id result, NSError *error){
        if (error)
            return;
        
        self.imageData = (UIImage *)result;
    }];
}


- (void)refreshProfileInfo
{
    [[MQWebServices sharedInstance] fetchProfileInfo:self completionBlock:^(id result, NSError *error){
        if (error)
            return;
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"REFRESH PROFILE INFO: %@", [results description]);
        NSString *confirmation = results[@"confirmation"];
        if ([confirmation isEqualToString:@"success"]==NO)
            return;
        
        [self populate:results[@"radius account"]]; //update profile with most refreshed data
    }];
}




- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"image":self.image, @"city":self.city, @"state":self.state, @"firstName":self.firstName, @"lastName":self.lastName, @"email":self.email, @"facebookId":self.facebookId, @"twitterId":self.twitterId, @"linkedinId":self.linkedinId, @"schools":self.schools, @"bio":self.bio, @"phone":self.phone, @"skills":self.skills, @"applications":self.applications}];
    
    // for properties that were added later, have to check for nil first
    if (self.resume != nil)
        params[@"resume"] = self.resume;

    if (self.video != nil)
        params[@"video"] = self.video;
    
    if (self.password==nil)
        return params;
    
    if ([self.password isEqualToString:@"none"])
        return params;

    params[@"password"] = self.password;
    return params;
}

- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}




@end
