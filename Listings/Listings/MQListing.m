//
//  MQListing.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.



#import "MQListing.h"
#import "MQWebServices.h"


@implementation MQListing
@synthesize uniqueId;
@synthesize profile;
@synthesize title;
@synthesize summary;
@synthesize city;
@synthesize image;
@synthesize imageData;
@synthesize timestamp;
@synthesize applications;
@synthesize formattedDate;
@synthesize icon;
@synthesize iconData;
@synthesize saved;

// these will evenutally come from the profile that created the listing:
@synthesize state;
@synthesize phone;
@synthesize email;
@synthesize venue;

- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
        self.profile = @"none";
        self.title = @"none";
        self.summary = @"none";
        self.city = @"none";
        self.state = @"none";
        self.phone = @"none";
        self.email = @"none";
        self.venue = @"none";
        self.icon = @"none";
        self.imageData = nil;
    }
    
    return self;
}

- (void)populate:(NSDictionary *)info
{
    for (NSString *key in info.allKeys) {
        if ([key isEqualToString:@"id"])
            self.uniqueId = [info objectForKey:key];

        if ([key isEqualToString:@"profile"])
            self.profile = [info objectForKey:key];
        
        if ([key isEqualToString:@"title"])
            self.title = [info objectForKey:key];

        if ([key isEqualToString:@"description"])
            self.summary = [info objectForKey:key];

        if ([key isEqualToString:@"city"])
            self.city = [info objectForKey:key];

        if ([key isEqualToString:@"state"])
            self.state = [info objectForKey:key];
        
        if ([key isEqualToString:@"phone"])
            self.phone = [info objectForKey:key];
        
        if ([key isEqualToString:@"email"])
            self.email = [info objectForKey:key];
        
        if ([key isEqualToString:@"venue"])
            self.venue = [info objectForKey:key];
        
        if ([key isEqualToString:@"image"])
            self.image = [info objectForKey:key];

        if ([key isEqualToString:@"icon"])
            self.icon = [info objectForKey:key];

        if ([key isEqualToString:@"applications"])
            self.applications = [info objectForKey:key];

        if ([key isEqualToString:@"saved"])
            self.saved = [info objectForKey:key];


        if ([key isEqualToString:@"timestamp"]){
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"]; //Tue Jun 17 00:52:49 UTC 2014
            
            NSString *ts = info[@"timestamp"];
            self.timestamp = [dateFormat dateFromString:ts];
            
            NSArray *parts = [ts componentsSeparatedByString:@" "];
            if (parts.count > 5){
                NSString *month = parts[1];
                NSString *day = parts[2];
                
                if ([day hasPrefix:@"0"])
                    day = [day stringByReplacingOccurrencesOfString:@"0" withString:@""];
                
                self.formattedDate = [NSString stringWithFormat:@"%@ %@", month, day];
            }
        }
    }
}

- (void)fetchImage
{
    if ([self.image isEqualToString:@"none"]) // no image, ignore
        return;
    
    [[MQWebServices sharedInstance] fetchImage:self.image completionBlock:^(id result, NSError *error){
        if (error){
            
        }
        else {
            UIImage *img = (UIImage *)result;
            self.imageData = img;
        }
        
    }];
}

- (void)fetchIcon
{
    if ([self.icon isEqualToString:@"none"]) // no image, ignore
        return;
    
    [[MQWebServices sharedInstance] fetchImage:self.icon completionBlock:^(id result, NSError *error){
        if (error){
            
        }
        else {
            UIImage *img = (UIImage *)result;
            self.iconData = img;
        }
        
    }];
    
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"title":self.title, @"summary":self.summary, @"city":self.city, @"image":self.image, @"venue":self.venue, @"state":self.state, @"phone":self.phone, @"email":self.email, @"applications":self.applications, @"icon":self.icon}];
    
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
