//
//  MQSearchHistoryViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/23/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSearchHistoryViewController.h"

@interface MQSearchHistoryViewController ()
@property (strong, nonatomic) UITableView *searchHistoryTable;
@end

@implementation MQSearchHistoryViewController
@synthesize locations;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Search History";

    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    CGRect frame = view.frame;

    self.searchHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-64.0f) style:UITableViewStylePlain];
    self.searchHistoryTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
    self.searchHistoryTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.searchHistoryTable.alpha = 0.85f;
    [view addSubview:self.searchHistoryTable];
    
    
    UIView *search = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    search.backgroundColor = [UIColor grayColor];
    search.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
    btnSearch.backgroundColor = [UIColor clearColor];
    btnSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSearch.layer.borderWidth = 1.5f;
    btnSearch.layer.cornerRadius = 4.0f;
    btnSearch.layer.masksToBounds = YES;
    btnSearch.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnSearch setTitle:@"SEARCH" forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchSelectedLocations) forControlEvents:UIControlEventTouchUpInside];
    [search addSubview:btnSearch];
    
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showAlertWithtTitle:@"Select Locations" message:@"Select up to five locations to search."];
}

- (void)exit:(UIBarButtonItem *)btn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.searches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f)];
        separator.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:separator];
    }
    
    
    NSString *location = self.profile.searches[indexPath.row];
    NSArray *parts = [location componentsSeparatedByString:@", "];
    if (parts.count > 1)
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [parts[0] capitalizedString], [parts[parts.count-1] uppercaseString]];
    else
        cell.textLabel.text = location;
    
    cell.textLabel.textColor = ([self.locations containsObject:location]) ? kGreen : [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *location = self.profile.searches[indexPath.row];
    if ([self.locations containsObject:location]){
        [self.locations removeObject:location];
        [self.searchHistoryTable reloadData];
        return;

    }
    
    if (self.locations.count >= 5){
        [self showAlertWithtTitle:@"Limit Reached" message:@"Please de-select a location before choosing another one."];
        return;
    }
    
    [self.locations addObject:location];
    [self.searchHistoryTable reloadData];
}

- (void)searchSelectedLocations
{
    if (self.locations.count==0){
        [self showAlertWithtTitle:@"No Locations Selected" message:@"Please select at least one location to search."];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNewSearchNotification object:nil]];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
