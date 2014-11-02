//
//  MQReferencesViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQReferencesViewController.h"


@interface MQReferencesViewController ()

@end

@implementation MQReferencesViewController
@synthesize publicProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"References";
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
//    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgLegsBlue.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:bgImage];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addReference:)];

}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addReference:(UIBarButtonItem *)btn
{
    NSLog(@"addReference: ");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
