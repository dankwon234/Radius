//
//  MQWebServices.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQProfile.h"
#import "MQPublicProfile.h"
#import "MQApplication.h"

typedef void (^MQWebServiceRequestCompletionBlock)(id result, NSError *error);

@interface MQWebServices : NSObject


+ (MQWebServices *)sharedInstance;

// Profile
- (void)registerProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)updateProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)login:(NSDictionary *)credentials completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchProfileInfo:(MQProfile *)profile completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)resumeRequest:(MQProfile *)profile completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchProfiles:(NSArray *)locations completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock;

// Public Profile
- (void)incrementView:(MQPublicProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;


// Listings
- (void)fetchListings:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchListings:(NSArray *)locations completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)saveListing:(MQListing *)listing forProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchSavedListings:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;


// Applications
- (void)fetchApplications:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)submitApplication:(MQApplication *)application completion:(MQWebServiceRequestCompletionBlock)completionBlock;


// Images
- (void)fetchImage:(NSString *)imageId completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchUploadString:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)cacheImage:(UIImage *)image toPath:(NSString *)filePath;
- (NSString *)createFilePath:(NSString *)fileName;

// Video
- (void)uploadVideo:(NSDictionary *)videoInfo toUrl:(NSString *)uploadUrl completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchVideoUploadString:(MQWebServiceRequestCompletionBlock)completionBlock;

// References
- (void)fetchReferences:(NSString *)profileId completion:(MQWebServiceRequestCompletionBlock)completionBlock;
- (void)requestReferences:(NSArray *)contacts forProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock;

// Introductions
- (void)submitIntroduction:(NSDictionary *)introduction completion:(MQWebServiceRequestCompletionBlock)completionBlock;



@end
