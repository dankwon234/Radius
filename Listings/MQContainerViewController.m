//
//  MQContainerViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQContainerViewController.h"
#import "MQListingsViewController.h"



@interface MQContainerViewController ()
@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) UINavigationController *navCtr;
@end

@implementation MQContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.listings = [NSMutableArray array];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor whiteColor];
    
    MQListingsViewController *listingsVc = [[MQListingsViewController alloc] init];
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:listingsVc];
    
    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];
    
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
