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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMenu)
                                                     name:@"ViewMenuNotification"
                                                   object:nil];

        
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

- (void)toggleMenu
{
//    NSLog(@"toggle menu: %.2f", );
    [UIView animateWithDuration:0.70f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         CGFloat halfWidth = 0.50f*frame.size.width;
                         CGPoint center = self.navCtr.view.center;
                         
                         if (center.x==halfWidth){
                             center.x = 0.95f*frame.size.width;
                         }
                         else{
                             center.x = halfWidth;
                         }
                         
                         
                         self.navCtr.view.center = center;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
