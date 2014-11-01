//
//  MQPublicProfileViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/1/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQPublicProfileViewController.h"

@interface MQPublicProfileViewController ()

@end

@implementation MQPublicProfileViewController
@synthesize publicProfile;



- (void)loadView
{
    UIView *view = [self baseView:YES];
    //    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"MQPublicProfileViewController: %@ %@", self.publicProfile.firstName, self.publicProfile.lastName);
    [self addCustomBackButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
