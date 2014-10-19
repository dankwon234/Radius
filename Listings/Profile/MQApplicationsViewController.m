//
//  MQApplicationsViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQApplicationsViewController.h"
#import "MQWebServices.h"

@interface MQApplicationsViewController ()
@property (strong, nonatomic) NSMutableArray *applications;
@property (strong, nonatomic) UITableView *applicationsTable;
@end

@implementation MQApplicationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.applications = [NSMutableArray array];
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        for (int i=0; i<a.count; i++)
            [self.applications addObject:[MQApplication applicationWithInfo:a[i]]];
        
        [self.applicationsTable reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.applications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    MQApplication *application = (MQApplication *)self.applications[indexPath.row];
    cell.textLabel.text = application.listing.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [application.listing.city capitalizedString], [application.listing.state uppercaseString]];
    
    return cell;
}




@end
