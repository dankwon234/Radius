//
//  MQLoginViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/15/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQLoginViewController.h"
#import "MQWebServices.h"
#import "MQAccountViewController.h"


@interface MQLoginViewController ()
@property (strong, nonatomic) NSMutableArray *textFields;
@end

@implementation MQLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Log In";
        self.textFields = [NSMutableArray array];

        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBlurry1Red.png"]];
    
    
    NSArray *fields = @[@"Email", @"Password"];
    CGFloat y = 94.0f;
    CGFloat h = 44.0f;
    UIFont *font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    UIColor *white = [UIColor whiteColor];
    UIColor *darkGray = [UIColor darkGrayColor];
    for (int i=0; i<fields.count; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
        textField.tag = 1000+i;
        textField.placeholder = fields[i];
        textField.backgroundColor = white;
        textField.alpha = 0.85f;
        textField.font = font;
        textField.textColor = darkGray;
        textField.delegate = self;
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, h)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
        textField.returnKeyType = (i==fields.count-1) ? UIReturnKeyDone : UIReturnKeyNext;
        if (i==1)
            textField.secureTextEntry = YES;
        
        [view addSubview:textField];
        y += textField.frame.size.height+0.5f;
        [self.textFields addObject:textField];
    }
    
    CGFloat padding = 12.0f;
    UIView *loginView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    loginView.backgroundColor = [UIColor grayColor];
    loginView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(padding, padding, frame.size.width-2*padding, h);
    btnLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnLogin.backgroundColor = [UIColor clearColor];
    btnLogin.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnLogin.layer.borderWidth = 1.5f;
    btnLogin.layer.cornerRadius = 4.0f;
    btnLogin.layer.masksToBounds = YES;
    btnLogin.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnLogin setTitle:@"LOG IN" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:btnLogin];
    
    [view addSubview:loginView];

    
    self.view = view;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]};
//    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barTintColor = kGreen;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"exit.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.7f*imgExit.size.width, 0.7f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];
}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)login:(UIButton *)btn
{
    NSLog(@"login: ");
    
    UITextField *emailField = self.textFields[0];
    if (emailField.text.length==0){
        [self showAlertWithtTitle:@"Missing Email" message:@"Please enter a valid email address."];
        return;
    }

    
    UITextField *pwField = self.textFields[1];
    if (pwField.text.length==0){
        [self showAlertWithtTitle:@"Missing Password" message:@"Please enter your password."];
        return;
    }

    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] login:@{@"email":emailField.text, @"password":pwField.text} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        NSString *confirmation = results[@"confirmation"];
        if ([confirmation isEqualToString:@"success"]==NO){
            [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            return;
        }
        
        NSDictionary *accountInfo = results[@"radius account"];
        [self.profile populate:accountInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MQAccountViewController *accountVc = [[MQAccountViewController alloc] init];
            [self.navigationController pushViewController:accountVc animated:YES];
        });
    }];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
