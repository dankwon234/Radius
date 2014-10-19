//
//  MQApplication.m
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQApplication.h"

@implementation MQApplication
@synthesize uniqueId;
@synthesize listing;
@synthesize profile;
@synthesize coverletter;


- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
        self.profile = @"none";
        self.coverletter = @"none";
        self.listing = nil;
    }
    
    return self;
}

+ (MQApplication *)applicationWithInfo:(NSDictionary *)info
{
    MQApplication *application = [[MQApplication alloc] init];
    [application populate:info];
    return application;
}


- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.profile = info[@"profile"];
    self.listing = [[MQListing alloc] init];
    [self.listing populate:info[@"listing"]];
    self.coverletter = info[@"coverletter"];
    
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"listing":[self.listing parametersDictionary], @"coverletter":self.coverletter}];
    
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
