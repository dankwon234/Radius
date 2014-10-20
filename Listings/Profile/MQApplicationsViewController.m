//
//  MQApplicationsViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQApplicationsViewController.h"
#import "MQListingViewController.h"
#import "MQWebServices.h"

@interface MQApplicationsViewController ()
@property (strong, nonatomic) UITableView *applicationsTable;
@end

@implementation MQApplicationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    
    self.applicationsTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.applicationsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.applicationsTable.dataSource = self;
    self.applicationsTable.delegate = self;
    [view addSubview:self.applicationsTable];
    

    
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.applicationsTable deselectRowAtIndexPath:[self.applicationsTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.profile.applications!=nil)
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
        
        NSString *confirmation = results[@"confirmation"];
        if ([confirmation isEqualToString:@"success"]==NO){
            [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            return;
        }
        
        NSArray *a = results[@"applications"];
        self.profile.applications = [NSMutableArray array];
        for (int i=0; i<a.count; i++){
            MQApplication *application = [MQApplication applicationWithInfo:a[i]];
            [self.profile.applications addObject:application];
            if ([application.listing.image isEqualToString:@"none"])
                continue;
            
            if (application.listing.imageData)
                continue;
            
            [application.listing fetchImage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.profile.applications.count==0)
                [self showAlertWithtTitle:@"No Applications" message:@"You have not applied to any jobs."];
            else
                [self.applicationsTable reloadData];
        });
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"iconData"]==NO)
        return;
    
    MQListing *listing = (MQListing *)object;
    [listing removeObserver:self forKeyPath:@"iconData"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.applicationsTable reloadData];
        
//      //this is smoother than a conventional reload. it doesn't stutter the UI:
//        int index = (int)[self.listings indexOfObject:listing];
//        MQListingCell *cell = (MQListingCell *)[self.listingsTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//        
//        if (!cell)
//            return;
//        
//        cell.icon.image = listing.iconData;
    });
    
    
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.applications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    MQApplication *application = (MQApplication *)self.profile.applications[indexPath.row];
    cell.textLabel.text = application.listing.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [application.listing.city capitalizedString], [application.listing.state uppercaseString]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MQApplication *application = self.profile.applications[indexPath.row];
    MQListingViewController *listingVc = [[MQListingViewController alloc] init];
    listingVc.listing = application.listing;
    
    listingVc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:listingVc animated:YES];
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
