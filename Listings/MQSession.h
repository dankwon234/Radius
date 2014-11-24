//
//  MQSession.h
//  Listings
//
//  Created by Dan Kwon on 11/23/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQSession : NSObject


@property (strong, nonatomic) NSMutableArray *profilesViewed;
@property (strong, nonatomic) NSMutableDictionary *profilesCache;
@property (strong, nonatomic) NSMutableDictionary *listingsCache;
+ (MQSession *)currentSession;
@end
