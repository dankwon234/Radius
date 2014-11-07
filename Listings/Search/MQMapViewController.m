//
//  MQMapViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/11/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQMapViewController.h"
#import "MQSearchLocationCell.h"


@interface MQMapViewController ()
@property (strong, nonatomic) UITableView *searchHistoryTable;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) MQLocationManager *locationMgr;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *btnSearch;
@property (strong, nonatomic) UIView *screen;
@property (nonatomic) int index;
@property (nonatomic) BOOL useMap;
@end

@implementation MQMapViewController
@synthesize locationMgr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationMgr = [MQLocationManager sharedLocationManager];
        self.title = @"Select Location";
        self.index = 0;
        self.useMap = YES;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    CGFloat height = frame.size.height+kNavBarHeight;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, height)];
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.locationMgr.currentLocation, 800, 800)];

    adjustedRegion.span.longitudeDelta  = 0.05f;
    adjustedRegion.span.latitudeDelta  = 0.05f;
    [self.mapView setRegion:adjustedRegion animated:YES];
    [view addSubview:self.mapView];
    
    
    self.screen = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.screen.backgroundColor = [UIColor whiteColor];
    self.screen.alpha = 0.0f;
    [self.screen addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBar:)]];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBar:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.screen addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBar:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.screen addGestureRecognizer:swipeRight];

    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBar:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.screen addGestureRecognizer:swipeDown];

    [view addSubview:self.screen];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"New York, NY";
    [view addSubview:self.searchBar];
    
    
    
    self.searchHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.searchHistoryTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
    self.searchHistoryTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.searchHistoryTable.contentInset = UIEdgeInsetsMake(0, 0, 96.0f, 0);
    self.searchHistoryTable.alpha = 0.90f;
    [view addSubview:self.searchHistoryTable];
    
    
    
    UIView *search = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    search.backgroundColor = [UIColor grayColor];
    search.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSearch.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
    self.btnSearch.backgroundColor = [UIColor clearColor];
    self.btnSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnSearch.layer.borderWidth = 1.5f;
    self.btnSearch.layer.cornerRadius = 4.0f;
    self.btnSearch.layer.masksToBounds = YES;
    self.btnSearch.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [self.btnSearch setTitle:@"SEARCH" forState:UIControlStateNormal];
    [self.btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSearch addTarget:self action:@selector(searchListings:) forControlEvents:UIControlEventTouchUpInside];
    [search addSubview:self.btnSearch];
    
    [view addSubview:search];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barTintColor = kOrange;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"exit.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.7f*imgExit.size.width, 0.7f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];

    UIImage *imgList = [UIImage imageNamed:@"iconList.png"];
    UIButton *btnList = [UIButton buttonWithType:UIButtonTypeCustom];
    btnList.frame = CGRectMake(0.0f, 0.0f, 0.65f*imgList.size.width, 0.65f*imgList.size.height);
    [btnList setBackgroundImage:imgList forState:UIControlStateNormal];
    [btnList addTarget:self action:@selector(toggleSearchTable:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnList];
    
}

- (void)exit:(UIBarButtonItem *)btn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)checkCoordinates
{
    self.index++;

    if (self.index >= 8){
        self.index = 0;
        NSLog(@"LOCATIONS: %@", [self.locationMgr.cities description]);
        [self.loadingIndicator stopLoading];
        
        BOOL updateProfile = NO;
        for (NSString *cityState in self.locationMgr.cities) {
            if ([self.profile.searches containsObject:cityState]==NO){
                [self.profile.searches insertObject:cityState atIndex:0];
                updateProfile = YES;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (updateProfile)
                [self.profile updateProfile];
        }];
        
        return;
    }
    
    for (NSString *cityState in self.locationMgr.cities) {
        if ([self.locationMgr.cities containsObject:cityState]==NO)
            [self.locationMgr.cities addObject:cityState];
    }

    CGFloat delta = 0.025f;
    CGPoint perimeter[9] = {CGPointMake(0, 0), CGPointMake(-delta, delta), CGPointMake(0.0, delta), CGPointMake(delta, delta), CGPointMake(delta, 0), CGPointMake(delta, -delta), CGPointMake(0, -delta), CGPointMake(-delta, -delta), CGPointMake(-delta, 0)};
    

    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    CGPoint point = perimeter[self.index];

    [self.locationMgr reverseGeocode:CLLocationCoordinate2DMake(center.latitude+point.x, center.longitude+point.y) completion:^{
        [self checkCoordinates];
    }];

}

- (void)searchListings:(UIButton *)btn
{
    if (self.useMap){
        [self.loadingIndicator startLoading];
        
        [self.locationMgr.cities removeAllObjects];
        CLLocationCoordinate2D center = self.mapView.centerCoordinate;
        [self.locationMgr.cities removeAllObjects];
        [self.locationMgr reverseGeocode:CLLocationCoordinate2DMake(center.latitude, center.longitude) completion:^{
            [self checkCoordinates];
        }];
        
        return;
    }
    
    if (self.locationMgr.cities.count==0){
        [self showAlertWithtTitle:@"No Locations Selected" message:@"Please select at least one location to search."];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)removeLocation:(UIButton *)btn
{
    NSLog(@"removeLocation: %d", (int)btn.tag);
    int tag = (int)btn.tag-1000;
    if (tag < 0)
        return;
    
    NSString *location = self.profile.searches[tag];
    if ([self.locationMgr.cities containsObject:location]) // location is currently selected, cannot remove
        return;
    
    NSLog(@"Remove Location: %@", location);
    [self.profile.searches removeObject:location];
    [self.searchHistoryTable reloadData];
    
    [self.profile updateProfile];
}

- (void)toggleSearchTable:(UIButton *)btn
{
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.searchHistoryTable.frame;
                         frame.origin.y = (frame.origin.y==64.0f) ? self.view.frame.size.height : 64.0f;
                         self.searchHistoryTable.frame = frame;
                     }
                     completion:^(BOOL finished){
                         self.useMap = !(self.searchHistoryTable.frame.origin.y==64.0f);

                     }];
}

- (void)dismissSearchBar:(UIGestureRecognizer *)tap
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.searchBar.text = @"";
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.screen.alpha = 0.9f;
                     }
                     completion:NULL];
    return YES;
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.screen.alpha = 0.0f;
                     }
                     completion:NULL];
    return YES;
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (self.searchBar.text.length == 0)
        return;
    
    NSString *searchTerm = self.searchBar.text;
    NSArray *parts = [searchTerm componentsSeparatedByString:@","];
    if (parts.count < 2){
        [self showAlertWithtTitle:@"Format Error" message:@"Please enter a city and state like this: 'new york, NY'"];
        return;
    }
    
    NSString *city = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *state = [parts[parts.count-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *cityState = [NSString stringWithFormat:@"%@, %@", [city lowercaseString], [state lowercaseString]];
    
    NSLog(@"SEARCH: %@", cityState);
    [self.locationMgr.cities removeAllObjects];
    [self.locationMgr.cities addObject:cityState];

    [self.searchBar resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.searches.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Search History";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    MQSearchLocationCell *cell = (MQSearchLocationCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[MQSearchLocationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [cell.btnRemove addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSString *location = self.profile.searches[indexPath.row];
    NSArray *parts = [location componentsSeparatedByString:@", "];
    cell.textLabel.text = (parts.count > 1) ? [NSString stringWithFormat:@"%@, %@", [parts[0] capitalizedString], [parts[parts.count-1] uppercaseString]] : location;
    
    cell.btnRemove.tag = 1000+indexPath.row;
    NSString *btnImage = ([self.locationMgr.cities containsObject:location]) ? @"iconSelected.png" : @"iconDeleteRed.png";
    [cell.btnRemove setBackgroundImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
    
    
    
    cell.textLabel.textColor = ([self.locationMgr.cities containsObject:location]) ? kGreen : [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *location = self.profile.searches[indexPath.row];
    if ([self.locationMgr.cities containsObject:location]){
        [self.locationMgr.cities removeObject:location];
        [self.searchHistoryTable reloadData];
        return;
        
    }
    
    if (self.locationMgr.cities.count >= 5){
        [self showAlertWithtTitle:@"Limit Reached" message:@"Please de-select a location before choosing another one."];
        return;
    }
    
    [self.locationMgr.cities addObject:location];
    [self.searchHistoryTable reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
