//
//  MQTutorialViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/7/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQTutorialViewController.h"

@interface MQTutorialViewController ()
@property (strong, nonatomic) UIScrollView *theScrollview;
@end

@implementation MQTutorialViewController


- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.theScrollview.pagingEnabled = YES;
    self.theScrollview.contentSize = CGSizeMake(4*frame.size.width, 0); // 4 pages
    [view addSubview:self.theScrollview];
    
    
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
