//
//  MQProfilesViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/27/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQProfilesViewController.h"
#import "MQWebServices.h"
#import "MQCollectionViewFlowLayout.h"
#import "MQListingCell.h"
#import "MQPublicProfile.h"

@interface MQProfilesViewController ()
@property (strong, nonatomic) UICollectionView *profilesTable;
@property (strong, nonatomic) NSMutableArray *profiles;
@end

static NSString *profileCellId = @"profileCellId";

@implementation MQProfilesViewController
@synthesize locationMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationMgr = [MQLocationManager sharedLocationManager];
        self.profiles = [NSMutableArray array];
        
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
//    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgBlurry1.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:bgImage];

    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *imgHamburger = [UIImage imageNamed:@"iconHamburger.png"];
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(0.0f, 0.0f, 0.5f*imgHamburger.size.width, 0.5f*imgHamburger.size.height);
    [btnMenu setBackgroundImage:imgHamburger forState:UIControlStateNormal];
    [btnMenu addTarget:self action:@selector(viewMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.profilesTable.collectionViewLayout invalidateLayout];
    
    
    
    [self searchProfiles];
}


- (void)searchProfiles
{
    if (self.locationMgr.cities.count==0)
        return;
    
//    self.lblLocation.text = [self.locations[0] uppercaseString];
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] fetchProfiles:self.locationMgr.cities completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        NSArray *accounts = results[@"accounts"];
        
        for (int i=0; i<accounts.count; i++) {
            MQPublicProfile *profile = [[MQPublicProfile alloc] init];
            [profile populate:accounts[i]];
            [self.profiles addObject:profile];
        }
        
        [self layoutProfilesCollectionView];

    }];
    
     
    
}


- (void)layoutProfilesCollectionView
{
    CGRect frame = self.view.frame;
    
    self.profilesTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, frame.size.width, frame.size.height-64.0f) collectionViewLayout:[[MQCollectionViewFlowLayout alloc] init]];
    self.profilesTable.backgroundColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.65f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 0.0f, 2.0f, frame.size.height)];
    line.backgroundColor = [UIColor darkGrayColor];
    [background addSubview:line];
    
    self.profilesTable.backgroundView = background;
    
    
    [self.profilesTable registerClass:[MQListingCell class] forCellWithReuseIdentifier:profileCellId];
    self.profilesTable.contentInset = UIEdgeInsetsMake(0.0f, 0, 12.0f, 0);
    self.profilesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.profilesTable.dataSource = self;
    self.profilesTable.delegate = self;
    self.profilesTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.profilesTable];
    
    [self refreshProfilesCollectionView];
}


- (void)refreshProfilesCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.profilesTable.collectionViewLayout invalidateLayout];
        [self.profilesTable reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.profiles.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.profilesTable reloadItemsAtIndexPaths:indexPaths];
    });
}




- (void)viewMenu:(id)sender
{
    NSLog(@"view menu");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kViewMenuNotification object:nil]];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    return self.profiles.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MQListingCell *cell = (MQListingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:profileCellId forIndexPath:indexPath];
    
    MQPublicProfile *profile = (MQPublicProfile *)self.profiles[indexPath.row];
    NSLog(@"PROFILE: %@ %@", profile.firstName, profile.lastName);
    cell.lblTitle.text = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
//    cell.lblVenue.text = listing.venue;
//    cell.lblDate.text = listing.formattedDate;
//    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [listing.city capitalizedString], [listing.state uppercaseString]];
//    cell.tag = indexPath.row+1000;
    
    
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kListingCellWidth, kListingCellHeight);
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
