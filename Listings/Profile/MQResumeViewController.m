//
//  MQResumeViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/24/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQResumeViewController.h"
#import "MQWebServices.h"

@interface MQResumeViewController ()
@property (strong, nonatomic) UIWebView *pdfWebview;
@end

@implementation MQResumeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Resume";

    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    self.pdfWebview = [[UIWebView alloc] initWithFrame:frame];
    self.pdfWebview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.pdfWebview.delegate = self;
    self.pdfWebview.scalesPageToFit = YES;
    [view addSubview:self.pdfWebview];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Change"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(changeResume:)];
    
    NSString *url = [kBaseUrl stringByAppendingString:[NSString stringWithFormat:@"site/pdf/%@", self.profile.resume]];
    [self.pdfWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)changeResume:(UIBarButtonItem *)btn
{
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] resumeRequest:self.profile completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = [NSString stringWithFormat:@"We sent a link to %@.\n\nTo upload your resume, click the link and login with your email and password.", [self.profile.email uppercaseString]];
            [self showNotification:@"Upload Resume" withMessage:msg];
        });
    }];
    

    
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingIndicator startLoading];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator stopLoading];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingIndicator stopLoading];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
