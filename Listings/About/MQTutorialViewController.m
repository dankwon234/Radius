//
//  MQTutorialViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/7/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQTutorialViewController.h"

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
    self.theScrollview.contentSize = CGSizeMake(4*frame.size.width, 0); // 4 pages
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    for (int i=0; i<4; i++) {
        UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(i*width, 0.0f, width, height)];
        cardView.backgroundColor = [UIColor clearColor];
        cardView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
        
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.7f*width, 0.7f*height)];
        card.backgroundColor = [UIColor whiteColor];
        card.layer.cornerRadius = 3.0f;
        card.layer.masksToBounds = YES;
        card.center = CGPointMake(0.5f*width, 0.5f*height);
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        logo.frame = CGRectMake(10.0f, 10.0f, 0.18f*logo.frame.size.width, 0.18f*logo.frame.size.height);
        [card addSubview:logo];

        
        
        [cardView addSubview:card];
        
        [self.theScrollview addSubview:cardView];
        
        
    }
    
    [view addSubview:self.theScrollview];
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
