//
//  MQSocialAccountsMgr.m
//  Listings
//
//  Created by Dan Kwon on 9/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSocialAccountsMgr.h"

@interface MQSocialAccountsMgr ()
@property (strong, nonatomic) LIALinkedInHttpClient *linkedInClient;
@end


@implementation MQSocialAccountsMgr
@synthesize accountStore;
@synthesize facebookAccount;
@synthesize twitterAccounts;
@synthesize selectedTwitterAccount;

#define kErrorDomain @"com.thegridmedia.radius"


+ (MQSocialAccountsMgr *)sharedAccountManager
{
    static MQSocialAccountsMgr *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[MQSocialAccountsMgr alloc] init];
        
    });
    
    return shared;
}


#pragma mark - Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *fbAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *dictFB = @{ACFacebookAppIdKey:kFacebookAppID, ACFacebookPermissionsKey:permissions};
    [self.accountStore requestAccessToAccountsWithType:fbAccountType options:dictFB completion:^(BOOL granted, NSError *e) {
        if (granted){
            if (e){
                NSLog(@"ERROR: %@", [e localizedDescription]);
                completionBlock(nil, e);
                return;
            }
            
            NSArray *accounts = [accountStore accountsWithAccountType:fbAccountType];
            ACAccount *fbAccount = [accounts lastObject]; //it will always be the last object with single sign on
            ACAccountCredential *facebookCredential = [fbAccount credential];
            NSString *accessToken = [facebookCredential oauthToken];
            NSLog(@"Facebook Access Token: %@", accessToken);
            
            self.facebookAccount = fbAccount;
            NSLog(@"facebook account = %@", fbAccount.username);
            completionBlock(self.facebookAccount, nil);
            return;
        }
        
        e = [NSError errorWithDomain:kErrorDomain code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
        NSLog(@"ERROR 2: %@", [e localizedDescription]);
        completionBlock(nil, e);
        
        
    }];
}

- (void)requestFacebookAccountInfo:(MQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.facebookAccount) { // no facebook acccount linked
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Facebook account linked. Please allow Facebook access."}];
        completionBlock(nil, error);
        return;
    }
    
    NSString *url = [kFacebookAPI stringByAppendingString:@"me"]; // https://graph.facebook.com/me
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *facebookAccountInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"FACEBOOK INFO: %@", [facebookAccountInfo description]);
            if (error) // JSON parsing error
                completionBlock(nil, error);
            else
                completionBlock(facebookAccountInfo, nil);
            
        }
        else { // handle error:
            NSLog(@"error from get - - %@", [error localizedDescription]); //attempt to revalidate credentials
            completionBlock(nil, error);
        }
        
    }];
}


#pragma mark - Twitter
- (void)requestTwitterAccess:(MQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted==NO) {
            error = [NSError errorWithDomain:kErrorDomain code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
            completionBlock(nil, error);
            return ;
        }
        
        NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
        self.twitterAccounts = accounts;
        
        // Check if the users has setup at least one Twitter account
//        if (accounts.count == 0) {
//            NSLog(@"No Twitter Acccounts found.");
//            return;
//        }
        
        completionBlock(self.twitterAccounts, nil);
    }];
    
}

- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock
{
    NSString *url = [kTwitterAPI stringByAppendingString:@"users/show.json"];
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:@{@"screen_name":twitterAccount.username}];
    twitterInfoRequest.account = twitterAccount;
    
    
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 429) { // Check if we reached the reate limit
            //            NSLog(@"Rate limit reached");
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Rate limit reached"}]);
            return;
        }
        
        
        if (error){
            completionBlock(nil, error);
            return;
        }
        
        if (!responseData) {
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Response Data"}]);
        }
        
        error = nil;
        NSDictionary *twitterAccountInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error){ // JSON parsing error
            completionBlock(nil, error);
            return;
        }
        
        //        NSLog(@"%@", [twitterAccountInfo description]);
        completionBlock(twitterAccountInfo, nil);
        
    }];
    
}

#pragma mark - LinkedIn
- (void)requestLinkedInAccess:(NSArray *)permissions fromViewController:(UIViewController *)vc completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock
{
    
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:kBaseUrl
                                                                                    clientId:kLinkedInClientID
                                                                                clientSecret:kLinkedInClientSecret
                                                                                       state:kLinkedInState
                                                                               grantedAccess:permissions];
    
    self.linkedInClient = [LIALinkedInHttpClient clientForApplication:application presentingViewController:vc];
    
    [self.linkedInClient getAuthorizationCode:^(NSString *code) {
        if (code==nil){
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Authorization Code is Nil."}]);
            return;
        }
        
        [self.linkedInClient getAccessToken:code
                                    success:^(NSDictionary *accessTokenData) {
                                        NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.linkedInClient GET:[kLinkedInAPI stringByAppendingString:@"people/~:(id,first-name,last-name,industry,picture-url,email-address,interests)"]
                                                          parameters:@{@"oauth2_access_token":accessToken, @"format":@"json"}
                                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                                                                 completionBlock(result, nil);
                                                             }
                                             
                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 //                                                             NSLog(@"failed to fetch current user %@", error);
                                                                 completionBlock(nil, error);
                                                             }];
                                        });
                                        
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Quering accessToken failed %@", error);
                                        completionBlock(nil, error);
                                    }];
    }
     
                                       cancel:^{
                                           NSLog(@"Authorization was cancelled by user");
                                           completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Authorization was cancelled by user"}]);
                                       }
     
                                      failure:^(NSError *error) {
                                          NSLog(@"Authorization failed %@", error);
                                          completionBlock(nil, error);
                                      }];
    
}



@end
