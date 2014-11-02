//
//  MQReference.m
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQReference.h"

@implementation MQReference
@synthesize uniqueId;
@synthesize profile;
@synthesize from;
@synthesize text;

- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
        self.profile = @"none";
        self.from = @"none";
        self.text = @"none";
    }
    
    return self;
}



- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.profile = info[@"profile"];
    self.from = info[@"from"];
    self.text = info[@"text"];

}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"from":self.from, @"text":self.text}];
    
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
