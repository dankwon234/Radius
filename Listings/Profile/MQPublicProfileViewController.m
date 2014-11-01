//
//  MQPublicProfileViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/1/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQPublicProfileViewController.h"

@interface MQPublicProfileViewController ()
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIImageView *profileIcon;
@property (strong, nonatomic) UILabel *lblProfileName;
@property (strong, nonatomic) UILabel *lblLocation;
@end

@implementation MQPublicProfileViewController
@synthesize publicProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Profile";

    }
    return self;
}


- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgLegsBlue.png"];
    self.background = [[UIImageView alloc] initWithImage:bgImage];
    self.background.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.background.frame = CGRectMake(0.0f, 0.0f, bgImage.size.width, bgImage.size.height);
    [view addSubview:self.background];
    
    self.blurryBackground = [[UIImageView alloc] initWithImage:[bgImage applyBlurOnImage:0.95f]];
    self.blurryBackground.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.blurryBackground.frame = CGRectMake(0.0f, 0.0f, bgImage.size.width, bgImage.size.height);
    self.blurryBackground.alpha = 0.0f;
    [view addSubview:self.blurryBackground];
    
    
    
    CGFloat dimen = 70.0f;
    self.profileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
    self.profileIcon.center = CGPointMake(0.5f*frame.size.width, 54.0f);
    self.profileIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.profileIcon.image = (self.publicProfile.imageData) ? self.publicProfile.imageData : [UIImage imageNamed:@"logo.png"];
    self.profileIcon.layer.cornerRadius = 0.5f*dimen;
    self.profileIcon.layer.masksToBounds = YES;
    self.profileIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileIcon.layer.borderWidth = 2.0f;
    [view addSubview:self.profileIcon];
    CGFloat y = self.profileIcon.frame.origin.y+self.profileIcon.frame.size.height+4.0f;

    
    self.lblProfileName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 22.0f)];
    self.lblProfileName.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblProfileName.textColor = [UIColor whiteColor];
    self.lblProfileName.textAlignment = NSTextAlignmentCenter;
    self.lblProfileName.text = [NSString stringWithFormat:@"%@ %@", self.publicProfile.firstName.uppercaseString, self.publicProfile.lastName.uppercaseString];
    self.lblProfileName.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [view addSubview:self.lblProfileName];
    y += self.lblProfileName.frame.size.height;

    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 16.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.textColor = [UIColor whiteColor];
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [self.publicProfile.city capitalizedString], self.publicProfile.state.uppercaseString];
    self.lblLocation.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height+40.0f;


    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    self.theScrollview.backgroundColor = [UIColor clearColor];
    self.theScrollview.showsVerticalScrollIndicator = NO;
    self.theScrollview.delegate = self;
//    [self.theScrollview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhoto:)]];
    
    
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 800.0f)];
    base.backgroundColor = [UIColor whiteColor];
    base.alpha = 0.9f;
    [self.theScrollview addSubview:base];

    self.theScrollview.contentSize = CGSizeMake(0.0f, 800.0f);
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [view addSubview:self.theScrollview];

    
    [self setupFullImage:view];

    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.theScrollview.contentOffset.y;
        if (offset < 0.0f){
            offset *= -1;
            double diff = offset;
            double factor = diff/250.0f;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f+factor, 1.0f+factor);
            self.background.transform = transform;
            self.profileIcon.transform = transform;
            self.profileIcon.alpha = 1.0f;
            self.lblProfileName.alpha = 1.0f;
            self.lblLocation.alpha = 1.0f;
            return;
        }
        
        double distance = offset;
        if (distance < 500.0f){
            CGRect frame = self.blurryBackground.frame;
            frame.origin.y = -0.25f*distance;
            self.blurryBackground.frame = frame;
            self.background.frame = frame;
        }
        
        self.profileIcon.alpha = 1.0f-(distance/100.0f);
        self.lblProfileName.alpha = self.profileIcon.alpha;
        self.lblLocation.alpha = self.profileIcon.alpha;
        
        // closer to zero, less blur applied
        double blurFactor = (offset + self.theScrollview.contentInset.top) / (2 * CGRectGetHeight(self.theScrollview.bounds) / 3.5f);
        self.blurryBackground.alpha = blurFactor;
    }
}

- (void)back:(UIBarButtonItem *)btn
{
    if (self.fullImageView.alpha==1.0f){
        [self exitFullImage:nil];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging: %.2f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -80.0f)
        [self viewFullImage:self.publicProfile.imageData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
