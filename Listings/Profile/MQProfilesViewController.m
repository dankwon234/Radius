//
//  MQProfilesViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/27/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQProfilesViewController.h"
#import "MQWebServices.h"
#import "MQProfilesCollectionViewFlowLayout.h"
#import "MQPublicProfile.h"
#import "MQProfileCollectionCell.h"
#import "MQMapViewController.h"


@interface MQProfilesViewController ()
@property (strong, nonatomic) UICollectionView *profilesTable;
@property (strong, nonatomic) NSMutableArray *profiles;
@property (nonatomic) BOOL needsRefresh;
@end

static NSString *profileCellId = @"profileCellId";

@implementation MQProfilesViewController
@synthesize locationMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.needsRefresh = YES;
        self.locationMgr = [MQLocationManager sharedLocationManager];
        self.profiles = [NSMutableArray array];
        
        UIImage *imgHeader = [UIImage imageNamed:@"header.png"];
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imgHeader.size.width, imgHeader.size.height)];
        header.backgroundColor = [UIColor colorWithPatternImage:imgHeader];
        self.navigationItem.titleView = header;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateNeedsRefresh)
                                                     name:kNewSearchNotification
                                                   object:nil];


    }
    return self;
    
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
//    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgLegsBlue.png"];
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
    
    UIImage *imgLocation = [UIImage imageNamed:@"iconLocation.png"];
    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocation.frame = CGRectMake(0.0f, 0.0f, 0.75f*imgLocation.size.width, 0.75f*imgLocation.size.height);
    [btnLocation setBackgroundImage:imgLocation forState:UIControlStateNormal];
    [btnLocation addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.profilesTable.collectionViewLayout invalidateLayout];
    
    if (self.needsRefresh)
        [self searchProfiles];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]==NO)
        return;
    
    MQPublicProfile *profile = (MQPublicProfile *)object;
    [profile removeObserver:self forKeyPath:@"imageData"];
    
    // this is smoother than a conventional reload. it doesn't stutter the UI:
    dispatch_async(dispatch_get_main_queue(), ^{
        int index = (int)[self.profiles indexOfObject:profile];
        MQProfileCollectionCell *cell = (MQProfileCollectionCell *)[self.profilesTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        if (!cell)
            return;
        
        cell.icon.image = profile.imageData;
        cell.backgroundImage.image = [profile.imageData applyBlurOnImage:0.95f];
    });
    
}


- (void)showMap:(UIButton *)btn
{
    MQMapViewController *mapVc = [[MQMapViewController alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:mapVc];
    [self presentViewController:navCtr animated:YES completion:^{
        
    }];
}

- (void)updateNeedsRefresh
{
    self.needsRefresh = YES;
}


- (void)searchProfiles
{
    self.needsRefresh = NO;

    if (self.locationMgr.cities.count==0)
        return;
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutProfilesCollectionView];
        });

    }];
    
     
    
}


- (void)layoutProfilesCollectionView
{
    if (self.profilesTable){
        [UIView animateWithDuration:0.40f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.profilesTable.frame;
                             self.profilesTable.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             self.profilesTable.delegate = nil;
                             self.profilesTable.dataSource = nil;
                             [self.profilesTable removeFromSuperview];
                             self.profilesTable = nil;
                             [self layoutProfilesCollectionView];
                         }];
        
        return;
    }

    CGRect frame = self.view.frame;
    
    self.profilesTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-64.0f) collectionViewLayout:[[MQProfilesCollectionViewFlowLayout alloc] init]];
    self.profilesTable.backgroundColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.65f;
    self.profilesTable.backgroundView = background;
    
    [self.profilesTable registerClass:[MQProfileCollectionCell class] forCellWithReuseIdentifier:profileCellId];
    self.profilesTable.contentInset = UIEdgeInsetsMake(0.0f, 0, 12.0f, 0);
    self.profilesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.profilesTable.dataSource = self;
    self.profilesTable.delegate = self;
    self.profilesTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.profilesTable];
    
    [self refreshProfilesCollectionView];
    
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.profilesTable.frame;
                         self.profilesTable.frame = CGRectMake(frame.origin.x, 64.0f, frame.size.width, frame.size.height-20.0f);
                     }
                     completion:^(BOOL finished){
                         
                     }];
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
    MQProfileCollectionCell *cell = (MQProfileCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:profileCellId forIndexPath:indexPath];
    
    MQPublicProfile *profile = (MQPublicProfile *)self.profiles[indexPath.row];
    
    NSLog(@"PROFILE: %@ %@", profile.firstName, profile.lastName);
    cell.lblName.text = [NSString stringWithFormat:@"%@ %@", [profile.firstName capitalizedString], [profile.lastName capitalizedString]];
    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [profile.city capitalizedString], [profile.state uppercaseString]];
    
//    cell.lblVenue.text = listing.venue;
//    cell.lblDate.text = listing.formattedDate;
//    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [listing.city capitalizedString], [listing.state uppercaseString]];
//    cell.tag = indexPath.row+1000;

    if (profile.imageData)
        cell.icon.image = profile.imageData;
    
    if ([profile.image isEqualToString:@"none"])
        return cell;
    
    [profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [profile fetchImage];
    
    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kProfileCellWidth, kProfileCellHeight);
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
