//
//  MQViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"

@implementation MQViewController
@synthesize profile;
@synthesize fullImageView;
@synthesize fullImage;
@synthesize notificationView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.profile = [MQProfile sharedProfile];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    self.loadingIndicator = [[MQLoadingIndicator alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.loadingIndicator.alpha = 0.0f;
    [self.view addSubview:self.loadingIndicator];
    
    self.notificationView = [[MQNotificationView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height)];
    self.notificationView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.notificationView.alpha = 0.0f;
    [self.view addSubview:self.notificationView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.notificationView.alpha = 0.0f;
    CGRect frame = self.notificationView.frame;
    frame.origin.y = self.view.frame.size.height;
    self.notificationView.frame = frame;
}

- (UIView *)baseView:(BOOL)navCtr
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.x = 0.0f;
    frame.origin.y = 0.0f;
    if (navCtr){
        
        // account for nav bar height, only necessary in iOS 7!
        frame.size.height -= 44.0f;
        
        [self.navigationController.navigationBar setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
          NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        
    }
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    return view;
}

- (void)addNavigationTitleView
{
    static CGFloat width = 200.0f;
    static CGFloat height = 46.0f;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    titleView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    titleView.backgroundColor = [UIColor clearColor];
    UIImage *imgLogo = [UIImage imageNamed:@"logo.png"];
    UIImageView *logo = [[UIImageView alloc] initWithImage:imgLogo];
    static double scale = 0.7f;
    CGRect frame = logo.frame;
    frame.size.width = scale*imgLogo.size.width;
    frame.size.height = scale*imgLogo.size.height;
    logo.frame = frame;
    logo.center = CGPointMake(0.45f*width, 24.0f);
    
    [titleView addSubview:logo];
    
    self.navigationItem.titleView = titleView;
    
}

- (void)addCustomBackButton
{
    UIColor *white = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = white;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : white};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.8f*imgExit.size.width, 0.8f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];
}

- (void)back:(UIBarButtonItem *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shiftUp:(CGFloat)distance
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = -distance;
                         self.view.frame = frame;
                     }
                     completion:NULL];
}

- (void)shiftBack:(CGFloat)origin
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = origin; // accounts for nav bar
                         self.view.frame = frame;
                     }
                     completion:NULL];
    
}

- (void)setupFullImage:(UIView *)view
{
    CGRect frame = view.frame;
    self.fullImageView = [[UIView alloc] initWithFrame:frame];
    self.fullImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.fullImageView.backgroundColor = [UIColor blackColor];
    self.fullImageView.alpha = 0.0f;
    
    CGFloat width = frame.size.width;
    self.fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, width)];
    self.fullImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.fullImage.center = CGPointMake(self.fullImage.center.x, self.fullImageView.center.y);
    [self.fullImageView addSubview:self.fullImage];
    
    [view addSubview:self.fullImageView];
}

- (void)viewFullImage:(UIImage *)image
{
    if (!image)
        return;
    
    NSLog(@"viewImage:");
    
    self.fullImage.image = image;
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 1.0f;
                         self.fullImageView.alpha = 1.0f;
                         
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)exitFullImage:(UIButton *)btn
{
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 0.0f;
                         self.fullImageView.alpha = 0.0f;
                         
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)showNotification:(NSString *)title withMessage:(NSString *)message
{
    self.notificationView.alpha = 1.0f;
    self.notificationView.lblTitle.text = title;
    self.notificationView.lblMessage.text = message;
    
    [UIView animateWithDuration:1.35f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect frame = self.notificationView.frame;
                         frame.origin.y = (self.edgesForExtendedLayout == UIRectEdgeNone) ? 0.0f : 64.0f;
                         self.notificationView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


#pragma mark - Alert
- (void)showAlertWithtTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)showAlertWithOptions:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
