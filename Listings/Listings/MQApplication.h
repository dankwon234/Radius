//
//  MQApplication.h
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQListing.h"

@interface MQApplication : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *profile; // id number of profile
@property (copy, nonatomic) NSString *coverletter;
@property (strong, nonatomic) MQListing *listing; 
+ (MQApplication *)applicationWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
