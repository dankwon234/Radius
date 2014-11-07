//
//  MQProfileViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/13/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQProfileViewController.h"
#import "MQSelectTwitterAccountViewController.h"
#import "MQResumeViewController.h"
#import "MQVideoViewController.h"
#import "MQWebServices.h"


@interface MQProfileViewController ()
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIImageView *profileIcon;
@property (strong, nonatomic) UILabel *lblProfileName;
@property (strong, nonatomic) UILabel *tapToChange;
@property (strong, nonatomic) UIButton *btnState;
@property (strong, nonatomic) UIPickerView *statePicker;
@property (strong, nonatomic) NSMutableArray *firstResponders;
@property (strong, nonatomic) NSMutableDictionary *states;
@property (strong, nonatomic) NSMutableArray *stateNames;
@property (nonatomic) BOOL requestTwitterAccess;
@property (nonatomic) BOOL imageUpdated;
@end

NSString *bioPlaceholder = @"Bio (tell us a little about yourself)";

@implementation MQProfileViewController
@synthesize socialMgr;
@synthesize currentSocialAccountUsername;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.requestTwitterAccess = NO;
        self.imageUpdated = NO;
        self.currentSocialAccountUsername = nil;

        self.socialMgr = [MQSocialAccountsMgr sharedAccountManager];
        self.firstResponders = [NSMutableArray array];
        self.states = [NSMutableDictionary dictionary];
        self.stateNames = [NSMutableArray array];
        self.title = @"Profile";
        
        NSArray *parts = [kStateAbbreviations componentsSeparatedByString:@","];
        for (int i=0; i<parts.count; i++) {
            NSString *state = [parts[i] lowercaseString];
            NSArray *p = [state componentsSeparatedByString:@" "];
            NSString *abbreviation = [p lastObject];
            
            NSString *stateName = [state substringToIndex:state.length-3];
            [self.stateNames addObject:stateName];
            self.states[stateName] = abbreviation;
        }

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

    UIImage *bgImage = [UIImage imageNamed:@"bgBlurry1.png"];
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
    self.profileIcon.image = [UIImage imageNamed:@"logo.png"];
    self.profileIcon.layer.cornerRadius = 0.5f*dimen;
    self.profileIcon.layer.masksToBounds = YES;
    self.profileIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileIcon.layer.borderWidth = 2.0f;
    [view addSubview:self.profileIcon];
    CGFloat y = self.profileIcon.frame.origin.y+self.profileIcon.frame.size.height;
    
    self.tapToChange = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 22.0f)];
    self.tapToChange.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.tapToChange.textColor = [UIColor whiteColor];
    self.tapToChange.textAlignment = NSTextAlignmentCenter;
    self.tapToChange.text = @"(tap to change)";
    self.tapToChange.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
    [view addSubview:self.tapToChange];
    y += self.tapToChange.frame.size.height+10.0f;
    
    
    self.lblProfileName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 22.0f)];
    self.lblProfileName.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblProfileName.textColor = [UIColor whiteColor];
    self.lblProfileName.textAlignment = NSTextAlignmentCenter;
    self.lblProfileName.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName.uppercaseString, self.profile.lastName.uppercaseString];
    self.lblProfileName.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [view addSubview:self.lblProfileName];
    y += self.lblProfileName.frame.size.height+36.0f;
    

    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    self.theScrollview.backgroundColor = [UIColor clearColor];
    self.theScrollview.showsVerticalScrollIndicator = NO;
    self.theScrollview.delegate = self;
    [self.theScrollview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhoto:)]];
    
    
    CGFloat h = 44.0f;
    CGFloat width = frame.size.width;
    UIFont *font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    UIColor *white = [UIColor whiteColor];
    UIColor *darkGray = [UIColor darkGrayColor];
    CGFloat alpha = 0.85f;
    int tag = 1000;
    
    NSArray *basicInfoFields = @[@"Name (first, last)", @"City", @"Phone Number"];
    for (int i=0; i<basicInfoFields.count; i++) {
        CGFloat w = (i==1) ? width-90.0f : width;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, w, h)];
        textField.placeholder = basicInfoFields[i];
        textField.tag = tag;
        textField.backgroundColor = white;
        textField.alpha = alpha;
        textField.font = font;
        textField.textColor = darkGray;
        textField.delegate = self;
        if (i==0) {
            NSString *fullName = @"";
            if ([self.profile.firstName isEqualToString:@"none"]==NO)
                fullName = [fullName stringByAppendingString:self.profile.firstName];

            if ([self.profile.lastName isEqualToString:@"none"]==NO)
                fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", self.profile.lastName]];
            
            textField.text = [fullName capitalizedString];
        }
        
        if (i==1) {
            if ([self.profile.city isEqualToString:@"none"]==NO)
                textField.text = [self.profile.city capitalizedString];
        }
        
        if (i==2) {
            textField.keyboardType = UIKeyboardTypePhonePad;
            if ([self.profile.phone isEqualToString:@"none"]==NO)
                textField.text = [self.profile formattedPhone];
            
        }
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, h)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
        
        [self.theScrollview addSubview:textField];
        [self.firstResponders addObject:textField];
        y += textField.frame.size.height+0.5f;
        tag++;
    }
    
    self.btnState = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnState.frame = CGRectMake(frame.size.width-89.5f, 223.5f, 89.5f, h);
    self.btnState.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnState.backgroundColor = white;
    self.btnState.alpha = alpha;
    self.btnState.titleLabel.font = font;
    if ([self.profile.state isEqualToString:@"none"])
        [self.btnState setTitle:@"NY" forState:UIControlStateNormal];
    else
        [self.btnState setTitle:self.profile.state.uppercaseString forState:UIControlStateNormal];

    [self.btnState addTarget:self action:@selector(selectState:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnState setTitleColor:darkGray forState:UIControlStateNormal];
    [self.theScrollview addSubview:self.btnState];
    
    // Bio text view:
    UIView *bioTextContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, width, 3*h)];
    bioTextContainer.backgroundColor = [UIColor whiteColor];
    bioTextContainer.alpha = alpha;
    UITextView *bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(25.0f, 4.0f, width-50.0f, 3*h-8.0f)];
    bioTextView.delegate = self;
    bioTextView.tag = 5000;
    bioTextView.font = font;
    if ([self.profile.bio isEqualToString:@"none"]) {
        bioTextView.text = bioPlaceholder;
        bioTextView.textColor = [UIColor lightGrayColor];
    }
    else {
        bioTextView.text = self.profile.bio;
        bioTextView.textColor = darkGray;
    }
    
    [bioTextContainer addSubview:bioTextView];
    [self.firstResponders addObject:bioTextView];
    [self.theScrollview addSubview:bioTextContainer];
    y += bioTextContainer.frame.size.height+0.5f;
    
    
    UILabel *lblHeaderExperience = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    lblHeaderExperience.textColor = [UIColor whiteColor];
    lblHeaderExperience.textAlignment = NSTextAlignmentCenter;
    lblHeaderExperience.font = font;
    lblHeaderExperience.text = @"BACKGROUND AND SKILLS";
    lblHeaderExperience.backgroundColor = [UIColor grayColor];
    [self.theScrollview addSubview:lblHeaderExperience];
    y += lblHeaderExperience.frame.size.height+0.5f;


//    NSArray *experienceFields = @[@"Skills (separated by commas)", @"Add School or College", @"Resume", @"Video"];
    NSArray *experienceFields = @[@"Skills (separated by commas)", @"Add School or College", @"Resume"];
    for (int i=0; i<experienceFields.count; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
        textField.placeholder = experienceFields[i];
        textField.tag = tag;
        textField.backgroundColor = white;
        textField.alpha = alpha;
        textField.font = font;
        textField.textColor = darkGray;
        textField.delegate = self;
        
        if (i==0){ // skillset
            if ([self.profile.skills containsObject:@"none"]==NO && self.profile.skills.count>0){
                NSString *skillset = @"";
                for (int j=0; j<self.profile.skills.count; j++) {
                    NSString *skill = self.profile.skills[j];
                    if (j==self.profile.skills.count-1)
                        skillset = [skillset stringByAppendingString:skill];
                    else
                        skillset = [skillset stringByAppendingString:[NSString stringWithFormat:@"%@, ", skill]];
                }
                textField.text = skillset;
            }
        }
        
        if (i==1){ // schools
            if ([self.profile.schools containsObject:@"none"]==NO && self.profile.schools.count>0){
                textField.text = [self.profile.schools[0] capitalizedString]; // just use first one for now
            }
        }
        
        
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, h)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
        
        [self.theScrollview addSubview:textField];
        [self.firstResponders addObject:textField];
        y += textField.frame.size.height+0.5f;
        tag++;
    }

    
    UILabel *lblSocialNetwork = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    lblSocialNetwork.textColor = [UIColor whiteColor];
    lblSocialNetwork.textAlignment = NSTextAlignmentCenter;
    lblSocialNetwork.font = font;
    lblSocialNetwork.text = @"LINKED SOCIAL NETWORK";
    lblSocialNetwork.backgroundColor = [UIColor grayColor];
    [self.theScrollview addSubview:lblSocialNetwork];
    y += lblSocialNetwork.frame.size.height+0.5f;

    
    NSArray *socialNetworks = @[@"Facebook", @"LinkedIn", @"Twitter"];
    for (int i=0; i<socialNetworks.count; i++) {
        UIView *bgNetworkLabel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
        bgNetworkLabel.tag = tag;
        bgNetworkLabel.backgroundColor = white;
        bgNetworkLabel.alpha = alpha;
        [bgNetworkLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNetwork:)]];
        
        
        UILabel *networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 10.0f, frame.size.width-64.0f, 20.0f)];
        networkLabel.font = font;
        networkLabel.textColor = [UIColor lightGrayColor];
        networkLabel.text = socialNetworks[i];
        networkLabel.tag = 3000;
        [bgNetworkLabel addSubview:networkLabel];
        
        UILabel *lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 29.0f, frame.size.width-64.0f, 10.0f)];
        lblUsername.tag = tag+2000;
        lblUsername.alpha = 0;
        lblUsername.textColor = [UIColor lightGrayColor];
        lblUsername.text = @"username";
        lblUsername.font = [UIFont italicSystemFontOfSize:10.0f];
        [bgNetworkLabel addSubview:lblUsername];
        
        UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCheckGreen.png"]];
        checkMark.tag = tag+1000;
        checkMark.alpha = 0.0f;
        checkMark.center = CGPointMake(frame.size.width-0.5f*checkMark.frame.size.width-6.0f, 0.5f*h);
        [bgNetworkLabel addSubview:checkMark];
        
        if (i==0){
            if ([self.profile.facebookId isEqualToString:@"none"]==NO){
                checkMark.alpha = 1.0f;
                networkLabel.textColor = kGreen;
                bgNetworkLabel.userInteractionEnabled = NO;
            }
        }
        
        if (i==1){
            if ([self.profile.linkedinId isEqualToString:@"none"]==NO){
                checkMark.alpha = 1.0f;
                networkLabel.textColor = kGreen;
                bgNetworkLabel.userInteractionEnabled = NO;
            }
        }

        if (i==2){
            if ([self.profile.twitterId isEqualToString:@"none"]==NO){
                checkMark.alpha = 1.0f;
                networkLabel.textColor = kGreen;
                bgNetworkLabel.userInteractionEnabled = NO;
            }
        }

        
        [self.theScrollview addSubview:bgNetworkLabel];
        y += bgNetworkLabel.frame.size.height+0.5f;
        tag++;
    }
    
    UIView *save = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, width, h+24.0f)];
    save.backgroundColor = [UIColor grayColor];
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(12.0, 12.0f, width-24.0f, h);
    btnSave.backgroundColor = [UIColor clearColor];
    btnSave.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSave.layer.borderWidth = 1.5f;
    btnSave.layer.cornerRadius = 4.0f;
    btnSave.layer.masksToBounds = YES;
    btnSave.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnSave setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveChanges:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSave];

    
    
    [save addSubview:btnSave];
    
    [self.theScrollview addSubview:save];
    y += save.frame.size.height;
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, width, 300.0f)];
    padding.backgroundColor = white;
    padding.alpha = alpha;
    [self.theScrollview addSubview:padding];

    self.theScrollview.contentSize = CGSizeMake(0.0f, y);

    
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [view addSubview:self.theScrollview];
    
    
    self.statePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, 220.0f)];
    self.statePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.statePicker.dataSource = self;
    self.statePicker.delegate = self;
    self.statePicker.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.statePicker];


    [self setupFullImage:view];

    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.requestTwitterAccess)
        return;
    
    [self requestTwitterAccountInfo];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];

    self.navigationController.navigationBar.barTintColor = kGreen;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:18.0f], NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    
    if (self.profile.imageData){
        self.profileIcon.image = self.profile.imageData;
        return;
    }
    
    if ([self.profile.image isEqualToString:@"none"])
        return;
    
    [self.profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [self.profile fetchImage];
}

- (void)back:(UIBarButtonItem *)btn
{
    if (self.fullImageView.alpha==1.0f){
        [self exitFullImage:nil];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        [self.profile removeObserver:self forKeyPath:@"imageData"];
        if (self.profile.imageData==nil)
            return;
        
        self.profileIcon.image = self.profile.imageData;
        [UIView transitionWithView:self.profileIcon
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.profileIcon.alpha = 1.0f;
                        }
                        completion:NULL];
        
    }
    
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
            self.tapToChange.alpha = 1.0f;
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
        self.tapToChange.alpha = self.profileIcon.alpha;
        
        
        // closer to zero, less blur applied
        double blurFactor = (offset + self.theScrollview.contentInset.top) / (2 * CGRectGetHeight(self.theScrollview.bounds) / 3.5f);
        
        self.blurryBackground.alpha = blurFactor;
        //        self.screen.alpha = MAX(0.0, MIN(self.blurryBackground.alpha - 0.2f, 0.2f));

    }
    
    
}



- (void)updateNetworkLabels:(int)tag
{
    UIView *bgNetworkLabel = (UIView *)[self.theScrollview viewWithTag:tag];
    bgNetworkLabel.userInteractionEnabled = NO;
    UILabel *lblNetwork = bgNetworkLabel.subviews[0];
    lblNetwork.textColor = [UIColor colorWithRed:110.0f/255.0f green:155.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
    
    UIImageView *checkMark = (UIImageView *)[bgNetworkLabel viewWithTag:(tag+1000)];
    [UIView transitionWithView:checkMark
                      duration:0.50f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if (self.currentSocialAccountUsername){
                            UILabel *lblUsername = (UILabel *)[bgNetworkLabel viewWithTag:tag+2000];
                            lblUsername.alpha = 1;
                            lblUsername.text = self.currentSocialAccountUsername;
                        }
                        
                        checkMark.alpha = 1.0f;
                    }
                    completion:NULL];
}


- (void)selectNetwork:(UIGestureRecognizer *)tap
{
    [self dismissKeyboard];

    int tag = (int)tap.view.tag;
    
    UILabel *lbl = (UILabel *)[tap.view viewWithTag:3000];
    NSString *network = [lbl.text lowercaseString];
    NSLog(@"selectNetwork: %@", network);
//    return;
    
    if ([network isEqualToString:@"facebook"]){ // facebook
        [self.loadingIndicator startLoading];
        [self.socialMgr requestFacebookAccess:kFacebookPermissions completionBlock:^(id result, NSError *error){
            if (error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    [self showAlertWithtTitle:@"Error" message:@"Facebook access is not granted for this app. Please check your settings."];
                });
                return;
            }
            
            [self.socialMgr requestFacebookAccountInfo:^(id result, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    if (error){
                        [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                        return;
                    }
                    
                    NSDictionary *facebookInfo = (NSDictionary *)result;
                    if (facebookInfo[@"id"])
                        self.profile.facebookId = facebookInfo[@"id"];
                    
                    NSString *fullName = @"";
                    if (facebookInfo[@"first_name"])
                        fullName = [fullName stringByAppendingString:facebookInfo[@"first_name"]];
                    
                    if (facebookInfo[@"last_name"])
                        fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", facebookInfo[@"last_name"]]];
                    
                    self.currentSocialAccountUsername = fullName;
                    
                    
                    [self updateNetworkLabels:tag];
                });
            }];
        }];
    }
    
    
    if ([network isEqualToString:@"linkedin"]){ // linkedin
        [self.loadingIndicator startLoading];
        [self.socialMgr requestLinkedInAccess:@[@"r_fullprofile", @"r_network", @"r_emailaddress"] fromViewController:self completionBlock:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            
            if (error){
                if (error.code != -1){
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                }
                return;
            }
            
            NSDictionary *linkedInInfo = (NSDictionary *)result;
            NSLog(@"LINKED IN PROFILE: %@", [linkedInInfo description]);
            
            NSString *fullName = @"";
            if (linkedInInfo[@"firstName"])
                fullName = [fullName stringByAppendingString:linkedInInfo[@"firstName"]];
            
            if (linkedInInfo[@"lastName"])
                fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", linkedInInfo[@"lastName"]]];
            
            self.currentSocialAccountUsername = fullName;
            self.profile.linkedinId = linkedInInfo[@"id"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNetworkLabels:tag];
            });
        }];
    }
    
    
    
    if ([network isEqualToString:@"twitter"]){ // twitter
        [self.loadingIndicator startLoading];
        [self.socialMgr requestTwitterAccess:^(id result, NSError *error){
            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSArray *twitterAccounts = (NSArray *)result;
            if (twitterAccounts.count == 0){
                [self showAlertWithtTitle:@"No Twitter Accounts" message:@"We did not find any Twitter accounts associated with this device."];
                return;
            }
            
            if (twitterAccounts.count > 0){
                NSLog(@"Found %d twitter accounts", (int)twitterAccounts.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    MQSelectTwitterAccountViewController *selectTwitterVc = [[MQSelectTwitterAccountViewController alloc] init];
                    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:selectTwitterVc];
                    [self presentViewController:navCtr animated:YES completion:^{
                        self.requestTwitterAccess = YES;
                    }];
                });
                
                return;
            }
            
            self.socialMgr.selectedTwitterAccount = self.socialMgr.twitterAccounts[0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestTwitterAccountInfo];
            });
            
        }];
    }
    
    
    
    //    if (tag==1003){ // instagram
    //        
    //    }
    
}



- (void)requestTwitterAccountInfo
{
    NSLog(@"requestTwitterAccountInfo");
    [self.socialMgr requestTwitterProfileInfo:self.socialMgr.selectedTwitterAccount completionBlock:^(id result, NSError *error){
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            
            NSDictionary *twitterAccountInfo = (NSDictionary *)result;
            NSLog(@"%@", [twitterAccountInfo description]);
            
            if (twitterAccountInfo[@"name"])
                self.currentSocialAccountUsername = twitterAccountInfo[@"name"];
            
            
            self.profile.twitterId = [NSString stringWithFormat:@"%@", twitterAccountInfo[@"id"]];
            [self updateNetworkLabels:1009];
            
        });
    }];
}

- (void)connectScrollviewDelegate
{
    self.theScrollview.delegate = self;
}

- (void)updateProfile:(UIView *)sender
{
    int tag = (int)sender.tag;
//    NSLog(@"UPDATE PROFILE: %d", tag);
    
    if (tag==5000){ // bio text view
        NSString *bio = [(UITextView *)sender text];
        if ([bio isEqualToString:bioPlaceholder]==NO)
            self.profile.bio = [(UITextView *)sender text];
        
        return;
    }
    
    UITextField *textField = (UITextField *)sender;
    if (tag==1000){ // name
        NSArray *parts = [textField.text componentsSeparatedByString:@" "];
        self.profile.firstName = parts[0];
        if (parts.count > 1)
            self.profile.lastName = [parts lastObject];
    }
    
    if (tag==1001) // city
        self.profile.city = textField.text;
    
    if (tag==1002) { // phone
        self.profile.phone = textField.text;
        textField.text = [self.profile formattedPhone];
    }
    
    if (tag==1003) { // skills
        NSArray *parts = [textField.text componentsSeparatedByString:@","];
        NSMutableArray *skills = [NSMutableArray array];
        for (int i=0; i<parts.count; i++) {
            NSString *skill = [parts[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (skill.length==0)
                continue;
            
            [skills addObject:[skill lowercaseString]];
        }
        
        self.profile.skills = skills;
    }
    
    if (tag==1004) { // school
        if (textField.text.length > 0){
            NSMutableArray *schools = [NSMutableArray array];
            [schools addObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            self.profile.schools = schools;
        }
    }

    
//    NSLog(@"%@", [self.profile jsonRepresentation]);
}


- (void)saveChanges:(UIButton *)btn
{
    if (self.imageUpdated){
        self.imageUpdated = NO;
        [self.loadingIndicator startLoading];
        [[MQWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
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
            
            NSString *upload = results[@"upload"]; // upload string
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadImage:upload];
            });
        }];
        
        return;
    }
    
    
    
//    NSLog(@"saveChanges: %@", [self.profile jsonRepresentation]);
    if (self.profile.firstName.length==0){
        [self showAlertWithtTitle:@"Missing First Name" message:@"Please enter a first name."];
        return;
    }
    
    if (self.profile.lastName.length==0){
        [self showAlertWithtTitle:@"Missing Last Name" message:@"Please enter a last name."];
        return;
    }

    if (self.profile.city.length==0){
        [self showAlertWithtTitle:@"Missing City" message:@"Please enter your city/town."];
        return;
    }

    if (self.profile.phone.length < 10){
        [self showAlertWithtTitle:@"Missing Phone Number" message:@"Please enter a valid phone number."];
        return;
    }

    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] updateProfile:self.profile completion:^(id result, NSError *error){
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
        
        [self.profile populate:results[@"radius account"]];
        self.lblProfileName.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName.uppercaseString, self.profile.lastName.uppercaseString];
        [self showAlertWithtTitle:@"Profile Updated" message:@"Your changes have been saved."];
    }];

}

- (void)selectPhoto:(UIGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self.theScrollview];
    if (location.y > 130.0f)
        return;
    
    
    NSLog(@"selectPhoto: %.2f, %.2f", location.x, location.y);
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"photo library", @"take photo", nil];
    actionsheet.frame = CGRectMake(0, 150.0f, self.view.frame.size.width, 100.0f);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)launchImageSelector:(UIImagePickerControllerSourceType)sourceType
{
    [self.loadingIndicator startLoading];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
    
}

- (void)uploadImage:(NSString *)upload
{
    NSLog(@"UPLOAD IMAGE: %@", upload);
    NSData *imageData = UIImageJPEGRepresentation(self.profile.imageData, 0.5f);
    NSDictionary *pkg = @{@"data":imageData, @"name":@"image.jpg"};
    MQWebServices *webServices = [MQWebServices sharedInstance];
    [webServices uploadImage:pkg toUrl:upload completion:^(id result, NSError *error){
        
        if (error){
            [self.loadingIndicator stopLoading];
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
        
        NSDictionary *imageInfo = results[@"image"];
        self.profile.image = imageInfo[@"id"];
        
        NSString *filePath = [webServices createFilePath:self.profile.image];
        [webServices cacheImage:self.profile.imageData toPath:filePath];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveChanges:nil];
        });
    }];
    
    
}



- (void)selectState:(UIButton *)btn
{
//    NSLog(@"selectState: ");
    [self dismissKeyboard];

    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 178.0f) animated:YES];
    [self performSelector:@selector(connectScrollviewDelegate) withObject:nil afterDelay:0.50f];

    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         self.statePicker.frame = CGRectMake(0.0f, frame.size.height-216.0f, frame.size.width, self.statePicker.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)dismissKeyboard
{
    for (UIView *firstResponder in self.firstResponders)
        [firstResponder resignFirstResponder];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
    [self dismissStatePicker];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging: %.2f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -80.0f)
        [self viewFullImage:self.profile.imageData];
}




#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissStatePicker];
    int tag = (int)textField.tag;
    NSLog(@"textFieldShouldBeginEditing: %d", tag);
    
    if (tag==1005){ // resume text field
        [self dismissKeyboard];
        if ([self.profile.resume isEqualToString:@"none"]){
            [self.loadingIndicator startLoading];
            [[MQWebServices sharedInstance] resumeRequest:self.profile completionBlock:^(id result, NSError *error){
                [self.loadingIndicator stopLoading];
                
                if (error){
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                    return;
                }
                
                NSDictionary *results = (NSDictionary *)result;
                NSLog(@"%@", [results description]);
                
                NSString *msg = [NSString stringWithFormat:@"We sent a link to %@.\n\nTo upload your resume, click the link and login with your email and password.", [self.profile.email uppercaseString]];
                [self showAlertWithtTitle:@"Upload Resume" message:msg];
            }];
            
            return NO;
        }
        
        // segue to resume view controller
        MQResumeViewController *resumeVc = [[MQResumeViewController alloc] init];
        [self.navigationController pushViewController:resumeVc animated:YES];
        return NO;
    }
    
//    if (tag==1006){ // video text field
//        [self dismissKeyboard];
//        MQVideoViewController *videoVc = [[MQVideoViewController alloc] init];
//        [self.navigationController pushViewController:videoVc animated:YES];
//        return NO;
//    }
    
    CGFloat offset = 0;
    
    if (tag < 1003)
        offset = 178.0f;
    
    else if (tag < 1005)
        offset = 444.0f;
    
    
    
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, offset) animated:YES];
    [self performSelector:@selector(connectScrollviewDelegate) withObject:nil afterDelay:0.50f];


    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int tag = (int)textField.tag;
    NSLog(@"textField shouldChangeCharactersInRange: %d", tag);
    [self performSelector:@selector(updateProfile:) withObject:textField afterDelay:0.05f];
    
    
    return YES;
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissStatePicker];
    if ([textView.text isEqualToString:bioPlaceholder]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 312.0f) animated:YES];
    [self performSelector:@selector(connectScrollviewDelegate) withObject:nil afterDelay:0.40f];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(updateProfile:) withObject:textView afterDelay:0.05f];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0){
        self.profile.bio = @"";
        textView.text = bioPlaceholder;
        textView.textColor = [UIColor lightGrayColor];
    }

    
    return YES;
}


#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.stateNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.stateNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.profile.state = self.states[self.stateNames[row]];
    [self.btnState setTitle:self.profile.state.uppercaseString forState:UIControlStateNormal];
}

- (void)dismissStatePicker
{
    if (self.statePicker.frame.origin.y == self.view.frame.size.height)
        return;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         self.statePicker.frame = CGRectMake(0.0f, frame.size.height, frame.size.width, self.statePicker.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0){
        [self launchImageSelector:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (buttonIndex==1){
        [self launchImageSelector:UIImagePickerControllerSourceTypeCamera];
    }

}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: didFinishPickingMediaWithInfo: %@", [info description]);
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.5*(image.size.width-dimen), 0.5*(image.size.height-dimen), dimen, dimen));
        image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }
    
    self.profileIcon.image = image;
    self.profile.imageData = image;
    self.imageUpdated = YES;

    
    [picker dismissViewControllerAnimated:YES completion:^{
        //        PQCreatePostViewController *createPostVc = [[PQCreatePostViewController alloc] init];
        //        [self.navigationController pushViewController:createPostVc animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
