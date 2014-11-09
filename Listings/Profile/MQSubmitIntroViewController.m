//
//  MQSubmitIntroViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/8/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQSubmitIntroViewController.h"
#import "MQWebServices.h"

@interface MQSubmitIntroViewController ()
@property (strong, nonatomic) UITextView *introductionTextView;
@end

NSString *placeholderText = @"Greeting (recommended)";

@implementation MQSubmitIntroViewController
@synthesize introduction;
@synthesize publicProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Apply";
        self.introduction = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = kBaseGray;
    CGRect frame = view.frame;
    
    CGFloat h = 0.7f*frame.size.width;
    CGFloat y = 64.0f;
    
    UIView *coverletterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    coverletterView.backgroundColor = [UIColor whiteColor];
    self.introductionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, frame.size.width-20, h-20)];
    self.introductionTextView.backgroundColor = [UIColor clearColor];
    self.introductionTextView.text = placeholderText;
    self.introductionTextView.delegate = self;
    self.introductionTextView.textColor = [UIColor lightGrayColor];
    self.introductionTextView.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard)];
    [btnDone setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44.0f)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], btnDone];
    
    [doneToolbar sizeToFit];
    self.introductionTextView.inputAccessoryView = doneToolbar;
    
    [coverletterView addSubview:self.introductionTextView];
    [view addSubview:coverletterView];
    y += h;
    
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
    shadow.frame = CGRectMake(0, y, shadow.frame.size.width, shadow.frame.size.height);
    [view addSubview:shadow];
    
    static CGFloat padding = 12.0f;
    y = frame.size.height-76.0f;
    UIButton *btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
    btnApply.frame = CGRectMake(padding, y, frame.size.width-2*padding, 44.0f);
    btnApply.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnApply.backgroundColor = [UIColor clearColor];
    btnApply.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    btnApply.layer.borderWidth = 1.5f;
    btnApply.layer.cornerRadius = 4.0f;
    btnApply.layer.masksToBounds = YES;
    [btnApply setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnApply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnApply addTarget:self action:@selector(submitIntroduction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnApply];
    
    
    self.view = view;

}


- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.introduction[@"profile"] = self.profile.uniqueId;
    self.introduction[@"text"] = @"";
    self.introduction[@"recipient"] = self.publicProfile.uniqueId;

    [self addCustomBackButton];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [self.publicProfile.firstName capitalizedString], [self.publicProfile.lastName capitalizedString]];
    NSString *msg = [NSString stringWithFormat:@"Personalize your introduction before connecting with %@.\n\nThis is a good opportunity to explain the type of employee you're looking for and why you think %@ may be a good fit.", fullName, fullName];
    [self showNotification:@"Greeting" withMessage:msg];
    
}

- (void)dismissKeyboard
{
    [self.introductionTextView resignFirstResponder];
}

- (void)submitIntroduction:(UIButton *)btn
{
    NSLog(@"submitIntroduction: %@", [self.introduction description]);
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] submitIntroduction:self.introduction completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", [self.publicProfile.firstName capitalizedString], [self.publicProfile.lastName capitalizedString]];
            NSString *msg = [NSString stringWithFormat:@"Thanks for connecting! %@ has been notified and will hopefully get back to you soon.", fullName];
            [self showAlertWithtTitle:@"Introduction Submitted" message:msg];
            
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
    
}

- (void)updateIntroduction
{
    if ([self.introductionTextView.text isEqualToString:placeholderText]){
        self.introduction[@"text"] = @"none";
        return;
    }
    
    self.introduction[@"text"] = self.introductionTextView.text;
    NSLog(@"%@", [self.introduction description]);
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholderText]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    if (textView.text.length==0){
        textView.text = placeholderText;
        textView.textColor = [UIColor lightGrayColor];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(updateIntroduction) withObject:nil afterDelay:0.05f];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
