//
//  MQResumeViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/24/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQResumeViewController.h"

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
    [view addSubview:self.pdfWebview];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *url = [kBaseUrl stringByAppendingString:[NSString stringWithFormat:@"pdf/%@", self.profile.resume]];
    [self.pdfWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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
