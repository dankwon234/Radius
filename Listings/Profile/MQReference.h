//
//  MQReference.h
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQReference : NSObject

@property (strong, nonatomic) NSString *uniqueId;
@property (strong, nonatomic) NSString *profile; // subject of reference
@property (strong, nonatomic) NSString *from; // person who wrote the reference
@property (strong, nonatomic) NSString *text;
- (void)populate:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
