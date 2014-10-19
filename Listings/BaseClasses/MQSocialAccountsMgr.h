//
//  MQSocialAccountsMgr.h
//  Listings
//
//  Created by Dan Kwon on 9/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "Config.h"

typedef void (^MQSocialAccountsMgrCompletionBlock)(id result, NSError *error);

@interface MQSocialAccountsMgr : NSObject


@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) ACAccount *selectedTwitterAccount;
+ (MQSocialAccountsMgr *)sharedAccountManager;

// Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestFacebookAccountInfo:(MQSocialAccountsMgrCompletionBlock)completionBlock;

// Twitter
- (void)requestTwitterAccess:(MQSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock;

// LinkedIn
- (void)requestLinkedInAccess:(NSArray *)permissions fromViewController:(UIViewController *)vc completionBlock:(MQSocialAccountsMgrCompletionBlock)completionBlock;


@end
