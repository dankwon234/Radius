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
@property (strong, nonatomic) MQListingsViewController *listingsVc;
@property (strong, nonatomic) UITableView *sectionsTable;
@end

@implementation MQContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.listings = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMenu)
                                                     name:kViewMenuNotification
                                                   object:nil];

        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.sectionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 64.0f)];
    headerView.backgroundColor = [UIColor redColor];
    self.sectionsTable.tableHeaderView = headerView;
    
    [view addSubview:self.sectionsTable];
    
    
    
    
    self.listingsVc = [[MQListingsViewController alloc] init];
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.listingsVc];
    
    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];
    
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)toggleMenu:(NSTimeInterval)duration
{
    CGRect frame = self.view.frame;
    CGFloat halfWidth = 0.50f*frame.size.width;
    
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGPoint center = self.navCtr.view.center;
                         center.x = (center.x==halfWidth) ? frame.size.width : halfWidth;
                         self.navCtr.view.center = center;
                     }
                     completion:^(BOOL finished){
                         CGPoint center = self.navCtr.view.center;
                         self.listingsVc.view.userInteractionEnabled = (center.x==halfWidth);
                     }];
}

- (void)toggleMenu
{
    [self toggleMenu:0.70f];
//    CGRect frame = self.view.frame;
//    CGFloat halfWidth = 0.50f*frame.size.width;
//
//    [UIView animateWithDuration:0.70f
//                          delay:0
//         usingSpringWithDamping:0.5f
//          initialSpringVelocity:0.0f
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         CGPoint center = self.navCtr.view.center;
//                         center.x = (center.x==halfWidth) ? frame.size.width : halfWidth;
//                         self.navCtr.view.center = center;
//                     }
//                     completion:^(BOOL finished){
//                         CGPoint center = self.navCtr.view.center;
//                         self.listingsVc.view.userInteractionEnabled = (center.x==halfWidth);
//                     }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = self.view.frame;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect navFrame = self.navCtr.view.frame;
                         navFrame.origin.x = frame.size.width;
                         self.navCtr.view.frame = navFrame;
                     }
                     completion:^(BOOL finished){
                         [self toggleMenu:0.85f];
                         
                     }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
