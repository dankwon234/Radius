//
//  MQContainerViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQContainerViewController.h"
#import "MQListingsViewController.h"
#import "MQProfilesViewController.h"
#import "MQAccountViewController.h"
#import "MQSignupViewController.h"
#import "MQLoginViewController.h"


@interface MQContainerViewController ()
@property (strong, nonatomic) UINavigationController *navCtr;
@property (strong, nonatomic) MQListingsViewController *listingsVc;
@property (strong, nonatomic) MQProfilesViewController *profilesVc;
@property (strong, nonatomic) MQViewController *currentVc;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) UIButton *btnAccount;
@end

@implementation MQContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = @[@"Search Jobs", @"Search Candidates"];
        
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
    self.btnAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAccount.frame = CGRectMake(8.0f, 36.0f, frame.size.width, 22.0f);
    self.btnAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnAccount.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [self.btnAccount addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.btnAccount];
    self.sectionsTable.tableHeaderView = headerView;
    
    [view addSubview:self.sectionsTable];
    
    
    
    
    self.listingsVc = [[MQListingsViewController alloc] init];
    self.currentVc = self.listingsVc;
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.listingsVc];
    
    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];
    
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.navCtr.view addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.navCtr.view addGestureRecognizer:swipeRight];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *account = (self.profile.populated) ? self.profile.email : @"Log In";
    [self.btnAccount setTitle:account forState:UIControlStateNormal];
}

- (void)login:(UIButton *)btn
{
    NSLog(@"login:");
    if (self.profile.populated){
        MQAccountViewController *accountVc = [[MQAccountViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountVc];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
        return;
    }
    
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Radius" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Up", @"Log In", nil];
    actionsheet.frame = CGRectMake(0.0f, 150.0f, self.view.frame.size.width, 100.0f);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)showMenu
{
    CGPoint center = self.navCtr.view.center;
    if (center.x > 0.50f*self.view.frame.size.width)
        return;
    
    [self toggleMenu];
}

- (void)hideMenu
{
    CGPoint center = self.navCtr.view.center;
    if (center.x==0.50f*self.view.frame.size.width)
        return;
    
    [self toggleMenu];
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
                         center.x = (center.x==halfWidth) ? 1.15f*frame.size.width : halfWidth;
                         self.navCtr.view.center = center;
                     }
                     completion:^(BOOL finished){
                         CGPoint center = self.navCtr.view.center;
                         self.navCtr.topViewController.view.userInteractionEnabled = (center.x==halfWidth);
                         [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:YES];
                     }];
}

- (void)toggleMenu
{
    [self toggleMenu:0.70f];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    
    cell.textLabel.text = self.sections[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0){
        if ([self.currentVc isEqual:self.listingsVc]){
            [self toggleMenu];
            return;
        }
        
        self.currentVc = self.listingsVc;
    }
    if (indexPath.row==1){
        if (self.profilesVc){
            if ([self.currentVc isEqual:self.profilesVc]){
                [self toggleMenu];
                return;
            }
        }
        else{
            self.profilesVc = [[MQProfilesViewController alloc] init];
        }
        
        self.currentVc = self.profilesVc;
    }

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
                         if (indexPath.row==0){
                             [self.navCtr popToRootViewControllerAnimated:NO];
                         }
                         else {
                             [self.navCtr pushViewController:self.currentVc animated:NO];
                         }
                         
                         [self toggleMenu:0.85f];
                     }];

}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0) { // sign up
        MQSignupViewController *signupVc = [[MQSignupViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:signupVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
    }
    
    if (buttonIndex==1) { // log in
        MQLoginViewController *loginVc = [[MQLoginViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:loginVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
