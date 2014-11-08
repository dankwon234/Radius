//
//  MQTutorialViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/7/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQTutorialViewController.h"
#import "MQTutorialCard.h"

@interface MQTutorialViewController ()
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation MQTutorialViewController


- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLegsBlue.png"]];
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.theScrollview.pagingEnabled = YES;
    self.theScrollview.delegate = self;
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    NSArray *cards = @[@{@"title":@"Welcome!", @"image":@"shot1.png", @"description":@"Radius is the best new app for job seekers and employers alike.\n\nFind your perfect job or employee today!"}, @{@"title":@" Local", @"image":@"shot7.png", @"description":@"Need a babysitter in New York or a job in Sacramento?\n\nOn Radius, you can view the details of candidates and jobs in your area of choice."}, @{@"title":@"Convenient", @"image":@"shot2.png", @"description":@"When you find the perfect job, just press 'Apply.' Your profile info will be sent directly to the employer.\n\nWhen you find the perfect candidate, press 'Connect.' and the candidate will be notified!"}];
    
    for (int i=0; i<cards.count; i++) {
        NSDictionary *cardInfo = cards[i];
        MQTutorialCard *card = [[MQTutorialCard alloc] initWithFrame:CGRectMake(i*width, 0.0f, width, height)];
        card.lblTitle.text = cardInfo[@"title"];
        card.lblDescription.text = cardInfo[@"description"];
        card.backgroundImage.image = [UIImage imageNamed:cardInfo[@"image"]];
        
        
        [self.theScrollview addSubview:card];
    }
    
    self.theScrollview.contentSize = CGSizeMake(cards.count*frame.size.width, 0);
    [view addSubview:self.theScrollview];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-94.0f, frame.size.width, 20.0f)];
    self.pageControl.numberOfPages = cards.count;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:self.pageControl];
    
    UIView *exitView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    exitView.backgroundColor = [UIColor grayColor];
    exitView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
    btnSearch.backgroundColor = [UIColor clearColor];
    btnSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSearch.layer.borderWidth = 1.5f;
    btnSearch.layer.cornerRadius = 4.0f;
    btnSearch.layer.masksToBounds = YES;
    btnSearch.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnSearch setTitle:@"EXIT" forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [exitView addSubview:btnSearch];
    
    [view addSubview:exitView];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)exit:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSLog(@"PAGE: %.2f", page);
    self.pageControl.currentPage = (NSInteger)page;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
