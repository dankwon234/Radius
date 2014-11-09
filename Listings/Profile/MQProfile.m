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
@synthesize skills;
@synthesize populated;
@synthesize applications;
@synthesize references;
@synthesize resume;
@synthesize video;
@synthesize saved;
@synthesize searches;
@synthesize deviceToken;
@synthesize phone = _phone; // using a custom setter for this


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
        self.deviceToken = @"none";
        self.schools = [NSMutableArray array];
        self.skills = [NSMutableArray array];
        self.searches = [NSMutableArray array];
        self.references = nil;
        self.applications = nil;
        self.saved = nil;
        self.populated = NO;

        if ([self populateFromCache])
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

- (void)setPhone:(NSString *)phone
{
    _phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)formattedPhone
{
    if (self.phone.length <= 3)
        return self.phone;

    NSString *formattedPhone = [self.phone substringToIndex:3];
    formattedPhone = [formattedPhone stringByAppendingString:@"-"];
    if (self.phone.length <= 6){
        NSString *substring = [self.phone substringWithRange:NSMakeRange(3, self.phone.length-3)];
        formattedPhone = [formattedPhone stringByAppendingString:substring];
        return formattedPhone;
    }
    
    formattedPhone = [formattedPhone stringByAppendingString:[self.phone substringWithRange:NSMakeRange(3, 3)]];
    formattedPhone = [formattedPhone stringByAppendingString:@"-"];
    formattedPhone = [formattedPhone stringByAppendingString:[self.phone substringFromIndex:6]];
    return formattedPhone;
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
    self.deviceToken = [profileInfo objectForKey:@"deviceToken"];
    self.skills = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"skills"]];
    self.schools = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"schools"]];
    self.searches = [NSMutableArray arrayWithArray:[profileInfo objectForKey:@"searches"]];
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

- (BOOL)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"user"];
    if (!json)
        return NO;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"STORED PROFILE: %@", [profileInfo description]);
    
    if (error)
        return NO;
    
    [self populate:profileInfo];
    return YES;
}

- (void)updateProfile
{
    if ([self.uniqueId isEqualToString:@"none"])
        return;

    NSLog(@"updateProfile: %@", self.uniqueId);

    [[MQWebServices sharedInstance] updateProfile:self completion:^(id result, NSError *error){
        if (error)
            return;
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"PROFILE UPDATED: %@", [results description]);
        [self cacheProfile];
        
    }];
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
//    NSLog(@"REFRESH PROFILE INFO: %@", self.uniqueId);
    if ([self.uniqueId isEqualToString:@"none"])
        return;
    
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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"image":self.image, @"city":self.city, @"state":self.state, @"firstName":self.firstName, @"lastName":self.lastName, @"email":self.email, @"facebookId":self.facebookId, @"twitterId":self.twitterId, @"linkedinId":self.linkedinId, @"schools":self.schools, @"bio":self.bio, @"phone":self.phone, @"skills":self.skills}];
    
    // for properties that were added later, have to check for nil first
    if (self.deviceToken != nil)
        params[@"deviceToken"] = self.deviceToken;

    if (self.searches != nil)
        params[@"searches"] = self.searches;

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
