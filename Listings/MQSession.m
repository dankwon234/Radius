//
//  MQSession.m
//  Listings
//
//  Created by Dan Kwon on 11/23/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSession.h"

@implementation MQSession
@synthesize profilesViewed;
@synthesize profilesCache;
@synthesize listingsCache;

- (id)init
{
    self = [super init];
    if (self){
        self.profilesViewed = [NSMutableArray array];
        self.profilesCache = [NSMutableDictionary dictionary];
        self.listingsCache = [NSMutableDictionary dictionary];
    }
    return self;
}


+ (MQSession *)currentSession
{
    MQSession *session = [[MQSession alloc] init];
    return session;
}


@end
