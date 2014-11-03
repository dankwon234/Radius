//
//  MQWebServices.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQWebServices.h"
#import "AFNetworking.h"
#include <sys/xattr.h>


#define kErrorDomain @"com.mercurymq"
#define kBaseUrl @"http://www.mercurymq.com/"
#define kSSLBaseUrl @"https://www.mercurymq.com/"
#define kPathUpload @"/api/upload/"
#define kPathListings @"/api/listings/"
#define kPathImages @"/site/images/"
#define kPathProfile @"/api/radiusaccounts/"
#define kPathApplications @"/api/applications/"
#define kPathReferences @"/api/references/"
#define kPathLogin @"/api/radiuslogin/"


@implementation MQWebServices


+ (MQWebServices *)sharedInstance
{
    static MQWebServices *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[MQWebServices alloc] init];
        
    });
    
    return shared;
}



// - - - - - - - - - - - - - - - - - - PROFILE - - - - - - - - - - - - - - - - - -
#pragma mark - Profile

- (void)registerProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathProfile
       parameters:[profile parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock){
                      NSLog(@"REGISTRATION FAILED");
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];

}


- (void)updateProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager PUT:[kPathProfile stringByAppendingString:profile.uniqueId]
      parameters:[profile parametersDictionary]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock){
                      NSLog(@"updateProfile: UPDATE FAILED");
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


- (void)login:(NSDictionary *)credentials completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
//    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kSSLBaseUrl]];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    
    [manager POST:kPathLogin
       parameters:credentials
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // successfully logged in
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock){
                      NSLog(@"LOG IN FAILED");
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
    
}


- (void)fetchProfileInfo:(MQProfile *)profile completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager GET:[kPathProfile stringByAppendingString:profile.uniqueId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock){
                     NSLog(@"fetchProfileInfo: UPDATE FAILED");
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 }
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];

}


- (void)resumeRequest:(MQProfile *)profile completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager GET:[kPathProfile stringByAppendingString:profile.uniqueId]
      parameters:@{@"action":@"resume"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock){
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 }
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
    
}

- (void)fetchProfiles:(NSArray *)locations completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock
{
    //http://698.text-alert.appspot.com/api/radiusaccounts?locations=new+canaan,ct;montvale,nj


    NSString *locationsString = @"";
    for (int i=0; i<locations.count; i++) {
        NSString *location = locations[i];
        location = [location stringByReplacingOccurrencesOfString:@", " withString:@","];
        location = [location stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        locationsString = [locationsString stringByAppendingString:location];
        if (i != locations.count-1)
            locationsString = [locationsString stringByAppendingString:@";"];
    }
    
    NSLog(@"Location String: %@", locationsString);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathProfile
      parameters:@{@"locations":locationsString}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]==NO){
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);

                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];

}


// - - - - - - - - - - - - - - - - - - LISTINGS - - - - - - - - - - - - - - - - - -
#pragma mark - Listings

- (void)fetchListings:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathListings
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
    
}

- (void)fetchListings:(NSArray *)locations completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    NSString *locationsString = @"";
    for (int i=0; i<locations.count; i++) {
        NSString *location = locations[i];
        location = [location stringByReplacingOccurrencesOfString:@", " withString:@","];
        location = [location stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        locationsString = [locationsString stringByAppendingString:location];
        if (i != locations.count-1)
            locationsString = [locationsString stringByAppendingString:@";"];
    }
    
//    NSLog(@"LOCATIONS STRING: %@", locationsString);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathListings
      parameters:@{@"locations":locationsString}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)saveListing:(MQListing *)listing forProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager PUT:[kPathListings stringByAppendingString:listing.uniqueId]
      parameters:@{@"action":@"save", @"profile":profile.uniqueId}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }

                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}

- (void)fetchSavedListings:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathListings
      parameters:@{@"saved":profile.uniqueId}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


// - - - - - - - - - - - - - - - - - - APPLICATIONS - - - - - - - - - - - - - - - - - -
#pragma mark - Applications

- (void)fetchApplications:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathApplications
      parameters:@{@"radiusaccount":profile.uniqueId}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)submitApplication:(MQApplication *)application completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathApplications
       parameters:[application parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock){
//                      NSLog(@"REGISTRATION FAILED");
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


// - - - - - - - - - - - - - - - - - - IMAGES - - - - - - - - - - - - - - - - - -
#pragma mark - Images

- (void)fetchImage:(NSString *)imageId completionBlock:(MQWebServiceRequestCompletionBlock)completionBlock
{
    //check cache first:
    NSString *filePath = [self createFilePath:imageId];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data){
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"CACHED IMAGE: %@, %d bytes", imageId, (int)data.length);
        if (!image)
            NSLog(@"CACHED IMAGE IS NIL:");
        
        if (completionBlock)
            completionBlock(image, nil);
        
        return;
    }
    

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"image/jpeg", @"image/png"]];
    manager.responseSerializer = serializer;
    
    
    [manager GET:[kPathImages stringByAppendingString:imageId]
      parameters:@{@"crop":@"640"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //Save image to cache directory:
             UIImage *img = (UIImage *)responseObject;
             NSData *imgData = UIImageJPEGRepresentation(img, 1.0f);
//             [imgData writeToFile:filePath atomically:YES];
//             [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
             
             [self cacheImage:img toPath:filePath];

             img = [UIImage imageWithData:imgData];
             completionBlock(img, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)cacheImage:(UIImage *)image toPath:(NSString *)filePath
{
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    [imgData writeToFile:filePath atomically:YES];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
}


- (void)fetchUploadString:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathUpload
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock)
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  
              }
              
              
              //        NSLog(@"Success: %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //        NSLog(@"Error: %@", error);
              completionBlock(nil, error);
              
          }];
}


#pragma mark - Video

- (void)fetchVideoUploadString:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathUpload
      parameters:@{@"media":@"videos"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)uploadVideo:(NSDictionary *)videoInfo toUrl:(NSString *)uploadUrl completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    NSData *videoData = videoInfo[@"data"];
    NSString *videoName = videoInfo[@"name"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:videoData name:@"file" fileName:videoName mimeType:@"video/mp4"];
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock)
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  
              }
              
              
              //        NSLog(@"Success: %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //        NSLog(@"Error: %@", error);
              completionBlock(nil, error);
              
          }];
    
}

#pragma mark - References
- (void)requestReferences:(NSArray *)contacts forProfile:(MQProfile *)profile completion:(MQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathReferences
       parameters:@{@"action":@"request", @"requests":contacts, @"profile":profile.uniqueId}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]==NO){
                  if (completionBlock)
                      completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  
                  return;
              }
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];

}



- (AFHTTPRequestOperationManager *)requestManagerForJSONSerializiation
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
    
}


#pragma mark - FileSavingStuff:
- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	return filePath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}




@end
