//
//  MQSelectTwitterAccountViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/12/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSelectTwitterAccountViewController.h"


@interface MQSelectTwitterAccountViewController ()
@property (strong, nonatomic) UITableView *twitterAccountsTable;
@property (strong, nonatomic) UILabel *lblHeader;
@end

@implementation MQSelectTwitterAccountViewController
@synthesize socialMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;

        self.title = @"Twitter Accounts";
        self.socialMgr = [MQSocialAccountsMgr sharedAccountManager];
        
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    CGRect frame = view.frame;
    
    self.lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 64.0f)];
    self.lblHeader.text = @"Select an account:";
    self.lblHeader.textAlignment = NSTextAlignmentCenter;
    self.lblHeader.textColor = [UIColor grayColor];
    self.lblHeader.font = [UIFont boldSystemFontOfSize:16.0f];
    
    
    self.twitterAccountsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    self.twitterAccountsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.twitterAccountsTable.backgroundColor = view.backgroundColor;
    self.twitterAccountsTable.dataSource = self;
    self.twitterAccountsTable.delegate = self;
    [view addSubview:self.twitterAccountsTable];
    
    
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];

//    UIImage *imgBack = [UIImage imageNamed:@"backArrow.png"];
//    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnBack setBackgroundImage:imgBack forState:UIControlStateNormal];
//    btnBack.frame = CGRectMake(0.0f, 0.0f, imgBack.size.width, imgBack.size.height);
//    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    [self showAlertWithtTitle:@"Select Account" message:@"We found multiple Twitter accounts associated with this device. Please select one."];

}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.lblHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.lblHeader.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.socialMgr.twitterAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ACAccount *twitterAccount = self.socialMgr.twitterAccounts[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", twitterAccount.username];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACAccount *twitterAccount = self.socialMgr.twitterAccounts[indexPath.row];
    self.socialMgr.selectedTwitterAccount = twitterAccount;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
