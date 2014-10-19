//
//  MQAccountViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/17/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQAccountViewController.h"
#import "MQProfileViewController.h"
#import "MQApplicationsViewController.h"


@interface MQAccountViewController ()
@property (strong, nonatomic) NSMutableArray *panels;
@property (nonatomic) BOOL loaded;
@end

@implementation MQAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panels = [NSMutableArray array];
        self.loaded = NO;
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    CGFloat height = view.frame.size.height/3.0f;
    CGFloat width = frame.size.width;
    CGFloat alpha = 0.65f;
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    UIFont *detailFont = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    
    NSArray *colors = @[[UIColor redColor], [UIColor lightGrayColor], [UIColor yellowColor]];
    NSArray *sections = @[@"Profile", @"Applied", @"Services"];
    NSArray *details = @[@"Manage your profile details", @"View your job applications", @"Subsribe to premium services"];
    NSArray *icons = @[@"iconProfile.png", @"iconCheckMark.png", @"iconProfile.png"];
    
    for (int i=0; i<3; i++){
        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, width, height)];
        panel.tag = 1000+i;
        panel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [panel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionSelected:)]];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height+1.0f)];
        background.backgroundColor = colors[i];
        background.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        background.alpha = alpha;
        [panel addSubview:background];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icons[i]]];
        icon.center = CGPointMake(0.5f*frame.size.width, 0.25f*panel.frame.size.height);
        [panel addSubview:icon];
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 22.0f)];
        lblTitle.center = CGPointMake(lblTitle.center.x, 0.5f*panel.frame.size.height+4.0f);
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.font = titleFont;
        lblTitle.text = sections[i];
        [panel addSubview:lblTitle];
        
        UILabel *lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 22.0f)];
        lblDetails.center = CGPointMake(lblDetails.center.x, 0.5f*panel.frame.size.height+22.0f);
        lblDetails.textAlignment = NSTextAlignmentCenter;
        lblDetails.textColor = [UIColor whiteColor];
        lblDetails.font = detailFont;
        lblDetails.text = details[i];
        [panel addSubview:lblDetails];

        [view addSubview:panel];
        [self.panels addObject:panel];
    }
    

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barTintColor = kGreen;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"exit"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(exit)];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.loaded)
        return;
    
    CGFloat y = 64.0f;
    for (int i=0; i<self.panels.count; i++) {
        UIView *panel = self.panels[i];
        
        [UIView animateWithDuration:1.50f
                              delay:0.20*i
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             panel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                             CGRect frame = panel.frame;
                             frame.origin.y = y;
                             panel.frame = frame;
                         }
                         completion:^(BOOL finished){
                             self.loaded = YES;
                         }];
        
        y += panel.frame.size.height+1.0f;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)sectionSelected:(UIGestureRecognizer *)tap
{
    int tag = (int)tap.view.tag;
    NSLog(@"sectionSelected: %d", tag);
    
    if (tag==1000){ // profile
        MQProfileViewController *profileVc = [[MQProfileViewController alloc] init];
        [self.navigationController pushViewController:profileVc animated:YES];
    }
    
    if (tag==1001){ // Applications
        if (self.profile.applications.count==0){
            [self showAlertWithtTitle:@"No Applications" message:@"You have not applied to any jobs."];
            return;
        }

        MQApplicationsViewController *applicationsVc = [[MQApplicationsViewController alloc] init];
        [self.navigationController pushViewController:applicationsVc animated:YES];
    }

    if (tag==1002){ // Premium Services
        
        
    }

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
