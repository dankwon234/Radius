//
//  MQProfileListingsViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/23/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQProfileListingsViewController.h"
#import "MQListingViewController.h"
#import "MQWebServices.h"
#import "MQListingCell.h"
#import "MQCollectionViewFlowLayout.h"


@interface MQProfileListingsViewController ()
@property (strong, nonatomic) UICollectionView *applicationsCollection;
@property (strong, nonatomic) NSMutableArray *listings;
@end

@implementation MQProfileListingsViewController
@synthesize mode;
static NSString *applicationCellId = @"applicationCellId";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Applied";
        self.mode = @"applications";
        self.listings = [NSMutableArray array];
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    BOOL populated = NO;
    if ([self.mode isEqualToString:@"applications"]){
        if (self.profile.applications != nil){
            populated = YES;
            for (int i=0; i<self.profile.applications.count; i++) {
                MQApplication *application = self.profile.applications[i];
                [self.listings addObject:application.listing];
            }
        }
    }
    
    if ([self.mode isEqualToString:@"saved"]){
        if (self.profile.saved != nil){
            populated = YES;
            for (int i=0; i<self.profile.saved.count; i++)
                [self.listings addObject:self.profile.saved[i]];

        }
    }
    
    if (populated==NO){
        self.view = view;
        return;
    }
    
    self.applicationsCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) collectionViewLayout:[[MQCollectionViewFlowLayout alloc] init]];
    self.applicationsCollection.backgroundColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.65f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 0.0f, 2.0f, frame.size.height)];
    line.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    line.backgroundColor = [UIColor darkGrayColor];
    [background addSubview:line];
    
    self.applicationsCollection.backgroundView = background;
    [self.applicationsCollection registerClass:[MQListingCell class] forCellWithReuseIdentifier:applicationCellId];
    self.applicationsCollection.contentInset = UIEdgeInsetsMake(0.0f, 0, 12.0f, 0);
    self.applicationsCollection.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.applicationsCollection.dataSource = self;
    self.applicationsCollection.delegate = self;
    self.applicationsCollection.showsVerticalScrollIndicator = NO;
    [view addSubview:self.applicationsCollection];
    
    [self refreshListingsCollectionView];
    
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.applicationsCollection.collectionViewLayout invalidateLayout];
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    self.title = [self.mode capitalizedString];
    
    
    if ([self.mode isEqualToString:@"applications"]){
        if (self.profile.applications != nil)
            return;
        
        [self.loadingIndicator startLoading];
        [[MQWebServices sharedInstance] fetchApplications:self.profile completion:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            
            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            
            NSArray *a = results[@"applications"];
            self.profile.applications = [NSMutableArray array];
            for (int i=0; i<a.count; i++){
                MQApplication *application = [MQApplication applicationWithInfo:a[i]];
                [self.profile.applications addObject:application];
                [self.listings addObject:application.listing];
                if ([application.listing.image isEqualToString:@"none"])
                    continue;
                
                if (application.listing.imageData)
                    continue;
                
                [application.listing fetchImage];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.listings.count==0){
                    [self showAlertWithtTitle:@"No Applications" message:@"You have not applied to any jobs."];
                    return;
                }
                
                if (self.applicationsCollection){
                    [self removeCollectionView];
                    return;
                }
                
                [self layoutListsCollectionView:self.view];
                
            });
            
        }];
    }

    
    if ([self.mode isEqualToString:@"saved"]){
        if (self.profile.saved != nil)
            return;
        
        [self.loadingIndicator startLoading];
        [[MQWebServices sharedInstance] fetchSavedListings:self.profile completion:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            
            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            
            NSArray *a = results[@"listings"];
            self.profile.saved = [NSMutableArray array];
            for (int i=0; i<a.count; i++){
                MQListing *listing = [[MQListing alloc] init];
                [listing populate:a[i]];
                [self.profile.saved addObject:listing];
                [self.listings addObject:listing];
                if ([listing.image isEqualToString:@"none"])
                    continue;
                
                if (listing.imageData)
                    continue;
                
                [listing fetchImage];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.listings.count==0){
                    [self showAlertWithtTitle:@"No Saved Applications" message:@"You have not saved any jobs."];
                    return;
                }
                
                if (self.applicationsCollection){
                    [self removeCollectionView];
                    return;
                }
                
                [self layoutListsCollectionView:self.view];
                
            });
            
        }];
    }
    
}

- (void)back:(UIBarButtonItem *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)removeCollectionView
{
    [UIView animateWithDuration:0.40f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.applicationsCollection.frame;
                         self.applicationsCollection.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         self.applicationsCollection.delegate = nil;
                         self.applicationsCollection.dataSource = nil;
                         [self.applicationsCollection removeFromSuperview];
                         self.applicationsCollection = nil;
                         [self layoutListsCollectionView:self.view];
                     }];
}



- (void)layoutListsCollectionView:(UIView *)view
{
    CGRect frame = view.frame;
    
    self.applicationsCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-20.0f) collectionViewLayout:[[MQCollectionViewFlowLayout alloc] init]];
    self.applicationsCollection.backgroundColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.65f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 0.0f, 2.0f, frame.size.height)];
    line.backgroundColor = [UIColor darkGrayColor];
    [background addSubview:line];
    
    self.applicationsCollection.backgroundView = background;
    
    
    [self.applicationsCollection registerClass:[MQListingCell class] forCellWithReuseIdentifier:applicationCellId];
    self.applicationsCollection.contentInset = UIEdgeInsetsMake(0.0f, 0, 12.0f, 0);
    self.applicationsCollection.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.applicationsCollection.dataSource = self;
    self.applicationsCollection.delegate = self;
    self.applicationsCollection.showsVerticalScrollIndicator = NO;
    [view addSubview:self.applicationsCollection];
    
    [self refreshListingsCollectionView];
    
    
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.applicationsCollection.frame;
                         self.applicationsCollection.frame = CGRectMake(frame.origin.x, 64.0f, frame.size.width, frame.size.height-20.0f);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)refreshListingsCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.applicationsCollection.collectionViewLayout invalidateLayout];
        [self.applicationsCollection reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.listings.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.applicationsCollection reloadItemsAtIndexPaths:indexPaths];
    });
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"iconData"]==NO)
        return;
    
    MQListing *listing = (MQListing *)object;
    [listing removeObserver:self forKeyPath:@"iconData"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        int index = (int)[self.listings indexOfObject:listing];
        MQListingCell *cell = (MQListingCell *)[self.applicationsCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        if (!cell)
            return;
        
        cell.icon.image = listing.iconData;
    });
    
    
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listings.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MQListingCell *cell = (MQListingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:applicationCellId forIndexPath:indexPath];
    MQListing *listing = (MQListing *)self.listings[indexPath.row];
    cell.lblTitle.text = listing.title;
    cell.lblVenue.text = listing.venue;
    cell.lblDate.text = listing.formattedDate;
    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [listing.city capitalizedString], [listing.state uppercaseString]];
    cell.tag = indexPath.row+1000;
    
    if ([listing.icon isEqualToString:@"none"])
        return cell;
    
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
    MQListingCell *cell = (MQListingCell *)[self.applicationsCollection cellForItemAtIndexPath:indexPath];
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







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
