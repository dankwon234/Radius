//
//  MQListingViewController.m
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQListingViewController.h"
#import "MQListingHeaderCell.h"
#import "MQListingSummaryCell.h"
#import "UIColor+MQColorAdditions.h"
#import "MQDetailIcon.h"
#import "MQSignupViewController.h"
#import "MQLoginViewController.h"
#import "MQSubmitApplicationViewController.h"
#import "MQApplication.h"
#import "MQWebServices.h"



@interface MQListingViewController ()
@property (strong, nonatomic) UIImageView *venueIcon;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) NSMutableArray *detailIcons;
@end

@implementation MQListingViewController
@synthesize listing;

#define kTopInset 70.0f


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.detailIcons = [NSMutableArray array];
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = kBaseGray;
    CGRect frame = view.frame;
    
    UIImage *listingImage = self.listing.imageData;
    CGFloat h = listingImage.size.height;
    double aspectRatio = frame.size.width/frame.size.height;
    CGFloat w = aspectRatio * h;
    
    
    UIImage *cropped = [self.listing.imageData imageByCropping:CGRectMake(0.5f*(listingImage.size.width-w), 0.0f, w, h)];

    
    self.background = [[UIImageView alloc] initWithImage:cropped];
    self.background.backgroundColor = view.backgroundColor;
    self.background.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.background.frame = CGRectMake(0.0f, 0.0f, 1.12f*frame.size.width, 1.12f*frame.size.height);
    [view addSubview:self.background];
    
    self.blurryBackground = [[UIImageView alloc] initWithImage:[self.listing.imageData applyBlurOnImage:1.0f]];
    self.blurryBackground.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.blurryBackground.frame = CGRectMake(self.background.frame.origin.x, 0, self.background.frame.size.width, self.background.frame.size.height);
    self.blurryBackground.alpha = 1.0f;
    [view addSubview:self.blurryBackground];

    CGFloat y = 110.0f;
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, frame.size.height-y)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin);
    self.theScrollview.backgroundColor = [UIColor clearColor];
    self.theScrollview.showsVerticalScrollIndicator = NO;
    self.theScrollview.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 0.0f, 0.0f);
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 1000.0f)];
    base.backgroundColor = [UIColor whiteColor];
    base.alpha = 0.90f;
    
    [self.theScrollview addSubview:base];
    
    CGFloat padding = 12.0f;
    y = padding+8.0f;
    CGFloat width = base.frame.size.width-2*padding;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 50.0f)];
    lblTitle.textColor = [UIColor darkGrayColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = self.listing.title;
    lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
    [self.theScrollview addSubview:lblTitle];

    y = lblTitle.frame.size.height;
    
    
    CGFloat dimen = 70.0f;
    double centers[] = {0.20f, 0.50f, 0.80f};
    NSArray *detailTitles = @[[self.listing.city capitalizedString], self.listing.formattedDate, @"Save"];
    NSArray *icons = @[@"iconLocationBlue.png", @"iconCalendarGreen.png", @"iconSaveRed.png"];
    
    for (int i=0; i<3; i++) {
        UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, dimen, dimen)];
        detailView.center = CGPointMake(centers[i]*frame.size.width, detailView.center.y);
        
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.8f*dimen, 0.8f*dimen)];
        circle.center = CGPointMake(0.5f*dimen, 0.5f*dimen);
        circle.layer.cornerRadius = 0.5f*circle.frame.size.width;
        circle.layer.borderWidth = 0.5f;
        circle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        circle.layer.masksToBounds = YES;
        [detailView addSubview:circle];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icons[i]]];
        icon.frame = CGRectMake(padding, y, 0.45f*dimen, 0.45f*dimen);
        icon.center = circle.center;
        [detailView addSubview:icon];
        
        UILabel *lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, 12.0f)];
        lblDetail.center = CGPointMake(0.5f*dimen, dimen+1.0f);
        lblDetail.font = [UIFont fontWithName:@"Heiti SC" size:10.0f];
        lblDetail.textAlignment = NSTextAlignmentCenter;
        lblDetail.textColor = [UIColor darkGrayColor];
        lblDetail.text = detailTitles[i];
        [detailView addSubview:lblDetail];
        
        
        [self.theScrollview addSubview:detailView];
    }
    

    
    
    y += dimen+2*padding;
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 500.0f)];
    bottom.backgroundColor = kBaseGray;
    bottom.alpha = 0.6f;
    [self.theScrollview addSubview:bottom];
    
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
    shadow.frame = CGRectMake(0.0f, y, shadow.frame.size.width, shadow.frame.size.height);
    [self.theScrollview addSubview:shadow];
    y += shadow.frame.size.height+padding;
    
    UIFont *summaryFont = [UIFont systemFontOfSize:14.0f];
    CGRect boudingRect = [self.listing.summary boundingRectWithSize:CGSizeMake(width, 450.0f)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:summaryFont}
                                                            context:NULL];

    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, boudingRect.size.height)];
    lblDescription.textColor = [UIColor darkGrayColor];
    lblDescription.font = summaryFont;
    lblDescription.numberOfLines = 0;
    lblDescription.text = self.listing.summary;
    lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
    [self.theScrollview addSubview:lblDescription];
    
    y += boudingRect.size.height+padding;
    
    NSLog(@"HEIGHT = %.2f", lblDescription.frame.size.height);
    if (lblDescription.frame.size.height < 110.0f)
        y += 110.0f;

    UIButton *btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
    btnApply.frame = CGRectMake(padding, y, width, 44.0f);
    btnApply.layer.borderWidth = 1.5f;
    btnApply.layer.cornerRadius = 4.0f;
    btnApply.layer.masksToBounds = YES;
    btnApply.backgroundColor = [UIColor clearColor];
    btnApply.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    [btnApply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    if ([self.listing.applications containsObject:self.profile.uniqueId]){
        [btnApply setTitle:@"APPLIED" forState:UIControlStateNormal];
    }
    else{
        [btnApply setTitle:@"APPLY" forState:UIControlStateNormal];
        [btnApply addTarget:self action:@selector(apply:) forControlEvents:UIControlEventTouchUpInside];
    }

    [self.theScrollview addSubview:btnApply];
    
    y += btnApply.frame.size.height;
    
    
    self.theScrollview.contentSize = CGSizeMake(0.0f, y+padding+20.0f);
    [view addSubview:self.theScrollview];
    
    
    
    self.venueIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, -70.0f, 60.0f, 60.0f)];
    self.venueIcon.center = CGPointMake(0.5f*frame.size.width, self.venueIcon.center.y);
    self.venueIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.venueIcon.layer.borderWidth = 2.0f;
    self.venueIcon.layer.cornerRadius = 0.5f*self.venueIcon.frame.size.width;
    self.venueIcon.layer.masksToBounds = YES;
    self.venueIcon.image = (self.listing.iconData) ? self.listing.iconData : [UIImage imageNamed:@"logo.png"];
    [view addSubview:self.venueIcon];

    
//    CGFloat iconDimen = 55.0f;
//    CGFloat offsets[] = {0.30f, 0.70f, 0.12f, 0.88f};
//    NSArray *details = @[@"9/20", @"$10", @"NEW YORK\nNY", @"SAVE"];
//    for (int i=0; i<4; i++) {
//        MQDetailIcon *icon = [[MQDetailIcon alloc] initWithFrame:CGRectMake(0.0f, 94.0f, iconDimen, 60.0f)];
//        icon.center = CGPointMake(offsets[i]*frame.size.width, icon.center.y);
//        icon.lblDetail.text = details[i];
//        [view addSubview:icon];
//        [self.detailIcons addObject:icon];
//    }
    
    
    
    self.view = view;
}


- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [UIView animateWithDuration:0.75f
                          delay:0.1f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.venueIcon.center = CGPointMake(self.venueIcon.center.x, self.theScrollview.frame.origin.y);

                     }
                     completion:NULL];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        UIScrollView *scrollview = self.theScrollview;
        CGFloat offset = scrollview.contentOffset.y;
        if (offset < -kTopInset){
            offset *= -1;
            double diff = offset-kTopInset;
            double factor = diff/250.0f;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f+factor, 1.0f+factor);
            self.background.transform = transform;
            return;
        }
        
        double distance = offset+kTopInset;
        if (distance < 400.0f){
            CGRect frame = self.blurryBackground.frame;
            frame.origin.y = -0.12f*distance;
            self.blurryBackground.frame = frame;
            self.background.frame = frame;
            
        }


        
        // closer to zero, less blur applied
        double blurFactor = (offset + scrollview.contentInset.top) / (2 * CGRectGetHeight(scrollview.bounds) / 6.5f);
        self.blurryBackground.alpha = blurFactor;
    }
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)saveListing:(UIButton *)btn
{
    if ([self.listing.saved containsObject:self.profile.uniqueId]) // already saved, ignore
        return;
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] saveListing:self.listing forProfile:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
    }];
}

- (void)apply:(UIButton *)btn
{
    if (self.profile.populated){
        
        MQApplication *application = [[MQApplication alloc] init];
        application.profile = self.profile.uniqueId;
        application.listing = self.listing;
        
        MQSubmitApplicationViewController *applicationVc = [[MQSubmitApplicationViewController alloc] init];
        applicationVc.application = application;
        [self.navigationController pushViewController:applicationVc animated:YES];
        return;
    }
    
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Apply" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Up", @"Log In", nil];
    actionsheet.frame = CGRectMake(0, 150, self.view.frame.size.width, 100);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    
    if (buttonIndex==0) { // sign up
        MQSignupViewController *signupVc = [[MQSignupViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:signupVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
    }

    if (buttonIndex==1) { // log in
        MQLoginViewController *loginVc = [[MQLoginViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:loginVc];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
        
    }

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
