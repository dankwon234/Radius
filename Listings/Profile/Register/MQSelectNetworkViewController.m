//
//  MQSelectNetworkViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSelectNetworkViewController.h"
#import "MQSelectTwitterAccountViewController.h"
#import "MQWebServices.h"
#import "MQAccountViewController.h"


@interface MQSelectNetworkViewController ()
@property (strong, nonatomic) NSMutableDictionary *states;
@property (copy, nonatomic) NSString *currentSocialAccountUsername;
@end

@implementation MQSelectNetworkViewController
@synthesize socialMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentSocialAccountUsername = nil;
        self.socialMgr = [MQSocialAccountsMgr sharedAccountManager];
        self.title = @"Select Network";
        
        self.states = [NSMutableDictionary dictionary];
        NSArray *parts = [kStateAbbreviations componentsSeparatedByString:@","];
        for (int i=0; i<parts.count; i++) {
            NSString *state = [parts[i] lowercaseString];
            NSArray *p = [state componentsSeparatedByString:@" "];
            NSString *abbreviation = [p lastObject];
            
            NSString *stateName = [state substringToIndex:state.length-3];
            self.states[stateName] = abbreviation;
        }
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBlurry1Red.png"]];
    
    CGFloat y = 88.0f;
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 24.0f)];
    lblHeader.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.text = @"LINK TO SOCIAL NETWORK";
    [view addSubview:lblHeader];
    y += lblHeader.frame.size.height;
    
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 44.0f)];
    lblDescription.textAlignment = NSTextAlignmentCenter;
    lblDescription.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
    lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
    lblDescription.numberOfLines = 0;
    lblDescription.textColor = [UIColor whiteColor];
    lblDescription.text = @"We use social network accounts to verify your\nprofile. Please select at least one.";
    [view addSubview:lblDescription];
    y += lblDescription.frame.size.height+20.0f;

    
    NSArray *networks = @[@"Facebook", @"LinkedIn", @"Twitter"];
    CGFloat h = 44.0f;
    UIFont *font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    UIColor *white = [UIColor whiteColor];
    UIColor *darkGray = [UIColor darkGrayColor];
    for (int i=0; i<networks.count; i++) {
        UIView *bgNetworkLabel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
        bgNetworkLabel.tag = 1000+i;
        bgNetworkLabel.backgroundColor = white;
        bgNetworkLabel.alpha = 0.85f;
        [bgNetworkLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNetwork:)]];
        
        
        UILabel *networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 10.0f, frame.size.width-64.0f, 20.0f)];
        networkLabel.font = font;
        networkLabel.textColor = darkGray;
        networkLabel.text = networks[i];
        [bgNetworkLabel addSubview:networkLabel];
        
        UILabel *lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 29.0f, frame.size.width-64.0f, 10.0f)];
        lblUsername.tag = 3000+i;
        lblUsername.alpha = 0;
        lblUsername.textColor = [UIColor lightGrayColor];
        lblUsername.text = @"username";
        lblUsername.font = [UIFont italicSystemFontOfSize:10.0f];
        [bgNetworkLabel addSubview:lblUsername];
        
        UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCheckGreen.png"]];
        checkMark.tag = 2000+i;
        checkMark.alpha = 0.0f;
        checkMark.center = CGPointMake(frame.size.width-0.5f*checkMark.frame.size.width-6.0f, 0.5f*h);
        [bgNetworkLabel addSubview:checkMark];

        [view addSubview:bgNetworkLabel];
        

        y += bgNetworkLabel.frame.size.height+0.5f;
    }
    

    
    
    
    CGFloat padding = 12.0f;
    UIView *registerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    registerView.backgroundColor = [UIColor grayColor];
    registerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(padding, padding, frame.size.width-2*padding, 44.0f);
    btnRegister.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnRegister.backgroundColor = [UIColor clearColor];
    btnRegister.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnRegister.layer.borderWidth = 1.5f;
    btnRegister.layer.cornerRadius = 4.0f;
    btnRegister.layer.masksToBounds = YES;
    btnRegister.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnRegister setTitle:@"REGISTER" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(registerProfile:) forControlEvents:UIControlEventTouchUpInside];
    [registerView addSubview:btnRegister];
    
    [view addSubview:registerView];


    self.view = view;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.socialMgr.selectedTwitterAccount==nil)
        return;
    
    if ([self.profile.twitterId isEqualToString:@"none"]==NO)
        return;
    
    [self requestTwitterAccountInfo];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)registerProfile:(UIButton *)btn
{
    NSLog(@"registerProfile: ");
    
    BOOL confirmed = NO;
    NSArray *socialNetworkIds = @[self.profile.facebookId, self.profile.twitterId, self.profile.linkedinId];
    
    for (NSString *networkId in socialNetworkIds) {
        if ([networkId isEqualToString:@"none"]==NO){
            confirmed = YES;
            break;
        }
    }
    
    if (confirmed==NO){
        [self showAlertWithtTitle:@"Missing Social Network" message:@"Please connect with at least one social network."];
        return;
    }
    
    NSLog(@"%@", [self.profile parametersDictionary]);
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] updateProfile:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSString *confirmation = results[@"confirmation"];
        if ([confirmation isEqualToString:@"success"]==NO){
            [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MQAccountViewController *accountVc = [[MQAccountViewController alloc] init];
            [self.navigationController pushViewController:accountVc animated:YES];
        });
        
    }];
     
    
}

- (void)requestTwitterAccountInfo
{
    [self.socialMgr requestTwitterProfileInfo:self.socialMgr.selectedTwitterAccount completionBlock:^(id result, NSError *error){
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            
            NSDictionary *twitterAccountInfo = (NSDictionary *)result;
            NSLog(@"%@", [twitterAccountInfo description]);
            
            if (twitterAccountInfo[@"name"])
                self.currentSocialAccountUsername = twitterAccountInfo[@"name"];
            
            
            self.profile.twitterId = [NSString stringWithFormat:@"%@", twitterAccountInfo[@"id"]];
            [self updateNetworkLabels:1002];
            
        });
    }];
}

- (void)updateNetworkLabels:(int)tag
{
    UIView *bgNetworkLabel = (UIView *)[self.view viewWithTag:tag];
    bgNetworkLabel.userInteractionEnabled = NO;
    UILabel *lblNetwork = bgNetworkLabel.subviews[0];
    lblNetwork.textColor = kGreen;
    

    
    UIImageView *checkMark = (UIImageView *)[bgNetworkLabel viewWithTag:(tag+1000)];
    [UIView transitionWithView:checkMark
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if (self.currentSocialAccountUsername){
                            UILabel *lblUsername = (UILabel *)[bgNetworkLabel viewWithTag:tag+2000];
                            lblUsername.alpha = 1;
                            lblUsername.text = self.currentSocialAccountUsername;
                        }

                        checkMark.alpha = 1.0f;
                    }
                    completion:NULL];
}


- (void)selectNetwork:(UIGestureRecognizer *)tap
{
    int tag = (int)tap.view.tag;
//    NSLog(@"selectNetwork: %d", tag);
    
    if (tag==1000){ // facebook
        [self.loadingIndicator startLoading];
        [self.socialMgr requestFacebookAccess:kFacebookPermissions completionBlock:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            [self.socialMgr requestFacebookAccountInfo:^(id result, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    if (error){
                        [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                        return;
                    }
                    
                    NSDictionary *facebookInfo = (NSDictionary *)result;
                    if (facebookInfo[@"id"])
                        self.profile.facebookId = facebookInfo[@"id"];
                    
                    NSString *fullName = @"";
                    if (facebookInfo[@"first_name"])
                        fullName = [fullName stringByAppendingString:facebookInfo[@"first_name"]];
                    
                    if (facebookInfo[@"last_name"])
                        fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", facebookInfo[@"last_name"]]];
                    
                    self.currentSocialAccountUsername = fullName;
                    
                    if (facebookInfo[@"location"]){
                        NSDictionary *locationInfo = facebookInfo[@"location"];
                        NSArray *parts = [locationInfo[@"name"] componentsSeparatedByString:@", "];
                        self.profile.city = [parts[0] lowercaseString];
                        if (parts.count > 1){
                            NSString *state = [parts[1] lowercaseString];
                            self.profile.state = (state.length > 2) ? self.states[state] : state;
                        }
                    }
                    
                    [self updateNetworkLabels:1000];
                });
            }];
        }];
    }
    
    
    if (tag==1001){ // linkedin
        [self.loadingIndicator startLoading];
        [self.socialMgr requestLinkedInAccess:@[@"r_fullprofile", @"r_network", @"r_emailaddress"] fromViewController:self completionBlock:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            
            if (error){
                if (error.code != -1){
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                }
                return;
            }
            
            NSDictionary *linkedInInfo = (NSDictionary *)result;
            NSLog(@"LINKED IN PROFILE: %@", [linkedInInfo description]);
            
            NSString *fullName = @"";
            if (linkedInInfo[@"firstName"])
                fullName = [fullName stringByAppendingString:linkedInInfo[@"firstName"]];
            
            if (linkedInInfo[@"lastName"])
                fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", linkedInInfo[@"lastName"]]];
            
            self.currentSocialAccountUsername = fullName;
            self.profile.linkedinId = linkedInInfo[@"id"];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNetworkLabels:tag];
            });
        }];
    }

    
    
    if (tag==1002){ // twitter
        [self.loadingIndicator startLoading];
        [self.socialMgr requestTwitterAccess:^(id result, NSError *error){
            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSArray *twitterAccounts = (NSArray *)result;
            if (twitterAccounts.count == 0){
                [self showAlertWithtTitle:@"No Twitter Accounts" message:@"We did not find any Twitter accounts associated with this device."];
                return;
            }
            
            if (twitterAccounts.count > 1){
                NSLog(@"Found %d twitter accounts", (int)twitterAccounts.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    MQSelectTwitterAccountViewController *selectTwitterVc = [[MQSelectTwitterAccountViewController alloc] init];
                    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:selectTwitterVc];
                    [self presentViewController:navCtr animated:YES completion:^{
                        
                    }];
                });
                
                return;
            }
            
            self.socialMgr.selectedTwitterAccount = self.socialMgr.twitterAccounts[0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestTwitterAccountInfo];
            });
            
        }];
    }

    
    
//    if (tag==1003){ // instagram
//        
//    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
