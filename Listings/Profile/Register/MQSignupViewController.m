//
//  MQSignupViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/28/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSignupViewController.h"
#import "MQSelectNetworkViewController.h"
#import "MQWebServices.h"

@interface MQSignupViewController ()
@property (strong, nonatomic) NSMutableArray *textFields;
@end

@implementation MQSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Create Your Profile";
        self.textFields = [NSMutableArray array];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGrandCentral.png"]];
    
    
    NSArray *fields = @[@"First Name", @"Last Name", @"Email", @"Password"];
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
        if (i==2)
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        
        if (i==3)
            textField.secureTextEntry = YES;
        
        [view addSubview:textField];
        y += textField.frame.size.height+0.5f;
        [self.textFields addObject:textField];
    }
    
    CGFloat padding = 12.0f;
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(padding, frame.size.height-h-padding, frame.size.width-2*padding, h);
    btnNext.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnNext.backgroundColor = [UIColor clearColor];
    btnNext.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnNext.layer.borderWidth = 1.5f;
    btnNext.layer.cornerRadius = 4.0f;
    btnNext.layer.masksToBounds = YES;
    btnNext.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(btnNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnNext];

    
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    
    UIImage *imgBack = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgBack forState:UIControlStateNormal];
    btnBack.frame = CGRectMake(0.0f, 0.0f, imgBack.size.width, imgBack.size.height);
    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)btnNextAction:(UIButton *)btn
{
    NSLog(@"btnNextAction:");
    
    BOOL complete = YES;
    for (int i=0; i<self.textFields.count; i++) {
        UITextField *textField = self.textFields[i];
        if (textField.text.length==0){
            complete = NO;
            break;
        }
    }
    
    if (complete==NO){
        [self showAlertWithtTitle:@"Missing Value" message:@"Please complete all fields."];
        return;
    }
    
    UITextField *emailField = self.textFields[2];
    if ([self isValidEmail:emailField.text strict:YES]==NO){
        [self showAlertWithtTitle:@"Invalid Email" message:@"Please enter a valid email address."];
        return;
    }

    UITextField *pwField = self.textFields[3];
    if (pwField.text.length < 6){
        [self showAlertWithtTitle:@"Password Too Short" message:@"Please enter a password with at least 6 characters."];
        return;
    }
    
    // Temporary: remove after setting up UI for MQProfileViewController
//    MQSelectNetworkViewController *selectNetworkVc = [[MQSelectNetworkViewController alloc] init];
//    [self.navigationController pushViewController:selectNetworkVc animated:YES];


    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] registerProfile:self.profile completion:^(id result, NSError *error){
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
        
        NSDictionary *profileInfo = results[@"radius account"];
        [self.profile populate:profileInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MQSelectNetworkViewController *selectNetworkVc = [[MQSelectNetworkViewController alloc] init];
            [self.navigationController pushViewController:selectNetworkVc animated:YES];
        });
        
    }];
     
}

- (void)updateProfile
{
    for (int i=0; i<self.textFields.count; i++) {
        UITextField *textField = self.textFields[i];
        
        if (i==0)
            self.profile.firstName = textField.text;
        
        if (i==1)
            self.profile.lastName = textField.text;

        if (i==2)
            self.profile.email = textField.text;

        if (i==3)
            self.profile.password = textField.text;

    }
    
    NSLog(@"%@", [self.profile jsonRepresentation]);
    
}


- (BOOL)isValidEmail:(NSString *)emailString strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self shiftUp:20.0f];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag < 1000+self.textFields.count-1){
        int nextTag = textField.tag+1;
        UITextField *nextTextField = (UITextField *)[self.view viewWithTag:nextTag];
        [nextTextField becomeFirstResponder];
        return YES;
    }
    
    [textField resignFirstResponder];
    [self shiftBack:64.0f];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateProfile) withObject:nil afterDelay:0.05f];
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
