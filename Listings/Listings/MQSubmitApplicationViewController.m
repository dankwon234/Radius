//
//  MQSubmitApplicationViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/18/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSubmitApplicationViewController.h"
#import "MQWebServices.h"


@interface MQSubmitApplicationViewController ()
@property (strong, nonatomic) UITextView *coverletterTextView;
@end

NSString *placeholder = @"Coverletter (optional)";

@implementation MQSubmitApplicationViewController
@synthesize application;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Apply";
        
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
    self.coverletterTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, frame.size.width-20, h-20)];
    self.coverletterTextView.backgroundColor = [UIColor clearColor];
    self.coverletterTextView.text = placeholder;
    self.coverletterTextView.delegate = self;
    self.coverletterTextView.textColor = [UIColor lightGrayColor];
    self.coverletterTextView.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44.0f)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)]];
    
    [doneToolbar sizeToFit];
    self.coverletterTextView.inputAccessoryView = doneToolbar;
    
    [coverletterView addSubview:self.coverletterTextView];
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
    [btnApply setTitle:@"SUBMIT APPLICATION" forState:UIControlStateNormal];
    [btnApply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnApply addTarget:self action:@selector(submitApplication:) forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyboard
{
    [self.coverletterTextView resignFirstResponder];
}

- (void)submitApplication:(UIButton *)btn
{
    NSLog(@"submitApplication: %@", [self.application jsonRepresentation]);
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] submitApplication:self.application completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        
        NSDictionary *results = (NSDictionary *)result;
        NSString *confirmation = results[@"confirmation"];
        if ([confirmation isEqualToString:@"success"]==NO){
            [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            return;
        }
        
//        [self.application populate:results[@"application"]];
        [self.application.listing populate:results[@"listing"]];
        [self.profile populate:results[@"radius account"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
    
}

- (void)updateApplication
{
    if ([self.coverletterTextView.text isEqualToString:placeholder]){
        self.application.coverletter = @"none";
        return;
    }
    
    self.application.coverletter = self.coverletterTextView.text;
    NSLog(@"%@", [self.application jsonRepresentation]);
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholder]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    if (textView.text.length==0){
        textView.text = placeholder;
        textView.textColor = [UIColor lightGrayColor];
    }

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(updateApplication) withObject:nil afterDelay:0.05f];
    return YES;
}




@end
