//
//  MQListingsViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQListingsViewController.h"
#import "MQListingCell.h"
#import "MQCollectionViewFlowLayout.h"
#import "MQWebServices.h"
#import "MQMapViewController.h"
#import "MQListingViewController.h"
#import "MQSignupViewController.h"
#import "MQLoginViewController.h"
#import "MQAccountViewController.h"
#import "MQListing.h"


@interface MQListingsViewController ()
@property (strong, nonatomic) UICollectionView *listingsTable;
@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UIButton *btnProfile;
@property (strong, nonatomic) UIButton *btnAbout;
@property (strong, nonatomic) UILabel *lblLogin;
@property (nonatomic) BOOL needsRefresh;
@end

static NSString *cellId = @"cellId";

@implementation MQListingsViewController
@synthesize locationMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.needsRefresh = NO;
        self.locationMgr = [MQLocationManager sharedLocationManager];
        self.listings = nil;
        
        UIImage *imgHeader = [UIImage imageNamed:@"header.png"];
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imgHeader.size.width, imgHeader.size.height)];
        header.backgroundColor = [UIColor colorWithPatternImage:imgHeader];
        self.navigationItem.titleView = header;
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgSidewalk.png"]];
    CGRect frame = view.frame;
    
    CGFloat y = 76.0f;
    CGFloat dimen = 80.0f;
    
    self.btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnProfile.frame = CGRectMake(0, y, dimen, dimen);
    [self.btnProfile setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    self.btnProfile.center = CGPointMake(0.25f*frame.size.width, self.btnProfile.center.y);
    self.btnProfile.backgroundColor = [UIColor colorWithRed:156.0f/255.0f green:211.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
    self.btnProfile.layer.cornerRadius = 0.5f*dimen;
    self.btnProfile.layer.borderWidth = 2.0f;
    self.btnProfile.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnProfile.layer.masksToBounds = YES;
    [self.btnProfile addTarget:self action:@selector(btnProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnProfile];
    y += dimen-26.0f;
    
    self.lblLogin = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, 120.0f, 22.0f)];
    self.lblLogin.center = CGPointMake(self.btnProfile.center.x, self.lblLogin.center.y);
    self.lblLogin.textAlignment = NSTextAlignmentCenter;
    self.lblLogin.textColor = [UIColor whiteColor];
    self.lblLogin.font = [UIFont systemFontOfSize:12.0f];
    self.lblLogin.backgroundColor = [UIColor clearColor];
    self.lblLogin.text = @"Log in";
    [view addSubview:self.lblLogin];
    
    CGFloat x = self.btnProfile.frame.origin.x+self.btnProfile.frame.size.width;
    CGFloat width = frame.size.width-x-48.0f;
    
    UILabel *lblCurrent = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, 16.0f)];
    lblCurrent.center = CGPointMake(lblCurrent.center.x, self.btnProfile.center.y-16.0f);
    lblCurrent.text = @"currently searching";
    lblCurrent.textAlignment = NSTextAlignmentRight;
    lblCurrent.textColor = [UIColor whiteColor];
    lblCurrent.font = [UIFont fontWithName:@"Heiti SC" size:11.0f];
    [view addSubview:lblCurrent];
    
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, 0.0f, width, 22.0f)];
    self.lblLocation.center = CGPointMake(self.lblLocation.center.x, self.btnProfile.center.y);
    self.lblLocation.textAlignment = NSTextAlignmentRight;
    self.lblLocation.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    self.lblLocation.textColor = [UIColor blackColor];
    self.lblLocation.userInteractionEnabled = YES;
    [self.lblLocation addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMap:)]];
    [view addSubview:self.lblLocation];
    

    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = kLightBlue;
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *imgHamburger = [UIImage imageNamed:@"iconHamburger.png"];
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(0.0f, 0.0f, 0.5f*imgHamburger.size.width, 0.5f*imgHamburger.size.height);
    [btnMenu setBackgroundImage:imgHamburger forState:UIControlStateNormal];
    [btnMenu addTarget:self action:@selector(viewMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];

    
    UIImage *imgLocation = [UIImage imageNamed:@"iconLocation.png"];
    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocation.frame = CGRectMake(0.0f, 0.0f, 0.75f*imgLocation.size.width, 0.75f*imgLocation.size.height);
    [btnLocation setBackgroundImage:imgLocation forState:UIControlStateNormal];
    [btnLocation addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLocation];
    
    if ([self checkConnection]==NO){
        [self showAlertWithtTitle:@"No Connection" message:@"Please find an internet connection."];
        return;
    }
    
    
    [self.loadingIndicator startLoading];
    [self.locationMgr findLocation:^(NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithtTitle:@"Error" message:@"Failed to Get Your Location. Please check your settings to make sure location services is ativated (under 'Privacy' section)."];
            
            return;
        }
        
        NSLog(@"CALL BACK: %@", [self.locationMgr.cities description]);
        [self searchListings];
    }];


    if (self.profile.populated==NO)
        return;
    
    if ([self.profile.image isEqualToString:@"none"])
        return;
    
    if (self.profile.imageData)
        return;

    
    [self.profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [self.profile fetchImage];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.listingsTable.collectionViewLayout invalidateLayout];
    
    if (self.needsRefresh)
        [self searchListings];

    
    if (self.profile.imageData){
        [self.btnProfile setBackgroundImage:self.profile.imageData forState:UIControlStateNormal];
        self.lblLogin.alpha = 0.0f;
        return;
    }
    
    if ([self.profile.image isEqualToString:@"none"])
        return;
    
    [self.profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [self.profile fetchImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewSearchNotification object:nil];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"iconData"]){
        MQListing *listing = (MQListing *)object;
        [listing removeObserver:self forKeyPath:@"iconData"];
        
        // this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.listings indexOfObject:listing];
            MQListingCell *cell = (MQListingCell *)[self.listingsTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = listing.iconData;
        });
    }
    
    if ([keyPath isEqualToString:@"imageData"]){
        if (self.profile.imageData){
            [self.btnProfile setBackgroundImage:self.profile.imageData forState:UIControlStateNormal];
            self.lblLogin.alpha = 0.0f;
            [self.profile removeObserver:self forKeyPath:@"imageData"];
        }
    }
}

- (void)viewMenu:(id)sender
{
    NSLog(@"view menu");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kViewMenuNotification object:nil]];
}

- (void)updateNeedsRefresh
{
    self.needsRefresh = YES;
}


- (void)searchListings
{
    self.needsRefresh = NO;
    if (self.locationMgr.cities==0) // no locations listed, ignore
        return;
    
    BOOL updateProfile = NO;
    for (NSString *cityState in self.locationMgr.cities) {
        if ([self.profile.searches containsObject:cityState]==NO){
            [self.profile.searches addObject:cityState];
            updateProfile = YES;
        }
    }
    
    if (updateProfile)
        [self.profile updateProfile]; // update profile on backend with new search entries

    
    self.lblLocation.text = [self.locationMgr.cities[0] uppercaseString];

    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] fetchListings:self.locationMgr.cities completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            return;
        }
        
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        NSArray *list = results[@"listings"];
        
        if (list.count == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *parts = [self.locationMgr.cities[0] componentsSeparatedByString:@","];
                NSString *location = [parts[0] capitalizedString];
                if (parts.count > 1){
                    NSString *stateAbbreviation = [[parts lastObject] uppercaseString];
                    stateAbbreviation = [stateAbbreviation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", stateAbbreviation]];
                }
                
                NSString *msg = [NSString stringWithFormat:@"We didn't find any jobs in %@.\n\nTo change locations, tap the pin in the upper right corner.", location];

                [self showNotification:@"No Jobs!" withMessage:msg];
            });
            return;
        }
        
        self.listings = [NSMutableArray array];
        for (int i=0; i<list.count; i++) {
            MQListing *listing = [MQListing listingWithInfo:list[i]];
            [self.listings addObject:listing];
            if ([listing.image isEqualToString:@"none"]==NO && listing.imageData==nil)
                [listing fetchImage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutListsCollectionView];
        });
        
    }];
}


- (void)layoutListsCollectionView
{
    if (self.listingsTable){
        [UIView animateWithDuration:0.40f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.listingsTable.frame;
                             self.listingsTable.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             self.listingsTable.delegate = nil;
                             self.listingsTable.dataSource = nil;
                             [self.listingsTable removeFromSuperview];
                             self.listingsTable = nil;
                             [self layoutListsCollectionView];
                         }];
        
        return;
    }

    CGRect frame = self.view.frame;
    
    self.listingsTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-20.0f-180.0f) collectionViewLayout:[[MQCollectionViewFlowLayout alloc] init]];
    self.listingsTable.backgroundColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.65f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 0.0f, 2.0f, frame.size.height)];
    line.backgroundColor = [UIColor darkGrayColor];
    [background addSubview:line];
    
    self.listingsTable.backgroundView = background;
    
    
    [self.listingsTable registerClass:[MQListingCell class] forCellWithReuseIdentifier:cellId];
    self.listingsTable.contentInset = UIEdgeInsetsMake(0.0f, 0, 12.0f, 0);
    self.listingsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.listingsTable.dataSource = self;
    self.listingsTable.delegate = self;
    self.listingsTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.listingsTable];
    
    [self refreshListingsCollectionView];
    
    
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.listingsTable.frame;
                         self.listingsTable.frame = CGRectMake(frame.origin.x, 180.0f, frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         [self.view bringSubviewToFront:self.notificationView];
                         
                     }];
}

- (void)refreshListingsCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listingsTable.collectionViewLayout invalidateLayout];
        [self.listingsTable reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.listings.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.listingsTable reloadItemsAtIndexPaths:indexPaths];
    });
}

- (void)showMap:(UIButton *)btn
{
    MQMapViewController *mapVc = [[MQMapViewController alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:mapVc];
    [self presentViewController:navCtr animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateNeedsRefresh)
                                                     name:kNewSearchNotification
                                                   object:nil];
    }];
}


- (void)btnProfileAction:(UIButton *)btn
{
    NSLog(@"btnProfileAction: ");
    if (self.profile.populated){
        MQAccountViewController *accountVc = [[MQAccountViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountVc];
        [self.navigationController presentViewController:navController animated:YES completion:^{
            
        }];
        
        return;
    }
    
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Radius" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Up", @"Log In", nil];
    actionsheet.frame = CGRectMake(0, 150, self.view.frame.size.width, 100);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    return self.listings.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MQListingCell *cell = (MQListingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    MQListing *listing = (MQListing *)self.listings[indexPath.row];
    cell.lblTitle.text = listing.title;
    cell.lblVenue.text = listing.venue;
    cell.lblDate.text = listing.formattedDate;
    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [listing.city capitalizedString], [listing.state uppercaseString]];
    cell.tag = indexPath.row+1000;
    
    if ([listing.icon isEqualToString:@"none"]){
        cell.icon.image = [UIImage imageNamed:@"logo.png"];
        return cell;
    }

    if (listing.iconData){
        cell.icon.image = listing.iconData;
        return cell;
    }
    
    [listing addObserver:self forKeyPath:@"iconData" options:0 context:nil];
    [listing fetchIcon];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MQListingCell *cell = (MQListingCell *)[self.listingsTable cellForItemAtIndexPath:indexPath];
    if (cell.isRotated)
        return;
    
    MQListing *listing = self.listings[indexPath.row];
    MQListingViewController *listingVc = [[MQListingViewController alloc] init];
    listingVc.listing = listing;
    
    listingVc.view.backgroundColor = self.view.backgroundColor;
    
    [self.navigationController pushViewController:listingVc animated:YES];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kListingCellWidth, kListingCellHeight);
}



#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0) { // sign up
        MQSignupViewController *signupVc = [[MQSignupViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:signupVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
    }
    
    if (buttonIndex==1) { // log in
        MQLoginViewController *loginVc = [[MQLoginViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:loginVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
    }
    

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
