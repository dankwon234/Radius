//
//  MQProfilesViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/27/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQProfilesViewController.h"

@interface MQProfilesViewController ()

@end

@implementation MQProfilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewMenu:(id)sender
{
    NSLog(@"view menu");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kViewMenuNotification object:nil]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
