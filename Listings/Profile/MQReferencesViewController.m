//
//  MQReferencesViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQReferencesViewController.h"
#import "MQContactsViewController.h"
#import "MQWebServices.h"
#import "MQReferenceCell.h"

@interface MQReferencesViewController ()
@property (strong, nonatomic) UITableView *referencesTable;
@end

@implementation MQReferencesViewController
@synthesize publicProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"References";
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
   CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgLegsBlue.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(36.0f, 0.0f, 2.0f, frame.size.height)];
    line.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    line.backgroundColor = [UIColor whiteColor];
    [view addSubview:line];
    
    self.referencesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.referencesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.referencesTable.dataSource = self;
    self.referencesTable.delegate = self;
    self.referencesTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.referencesTable.backgroundColor = [UIColor clearColor];
    self.referencesTable.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 84.0f, 0.0f);
    [view addSubview:self.referencesTable];
    
    
    
    if (self.publicProfile==nil){
        UIView *requestReferenceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
        requestReferenceView.backgroundColor = [UIColor grayColor];
        requestReferenceView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

        UIButton *btnReference = [UIButton buttonWithType:UIButtonTypeCustom];
        btnReference.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
        btnReference.backgroundColor = [UIColor clearColor];
        btnReference.layer.borderColor = [[UIColor whiteColor] CGColor];
        btnReference.layer.borderWidth = 1.5f;
        btnReference.layer.cornerRadius = 4.0f;
        btnReference.layer.masksToBounds = YES;
        btnReference.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        [btnReference setTitle:@"REQUEST REFERENCE" forState:UIControlStateNormal];
        [btnReference setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnReference addTarget:self action:@selector(addReference:) forControlEvents:UIControlEventTouchUpInside];
        [requestReferenceView addSubview:btnReference];
        
        [view addSubview:requestReferenceView];
    }


    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    if (self.publicProfile){
        if (self.publicProfile.references){
            [self layoutReferencesTable];
            return;
        }
        
        [self fetchReferences:self.publicProfile.uniqueId];
        return;
    }
    
    
    
    if (self.profile.references){
        [self layoutReferencesTable];
        return;
    }
    
    [self fetchReferences:self.profile.uniqueId];
}

- (void)fetchReferences:(NSString *)profileId
{
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] fetchReferences:profileId completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSArray *r = results[@"references"];
        NSMutableArray *references = [NSMutableArray array];
        for (int i=0;i<r.count; i++) {
            NSMutableDictionary *reference = [NSMutableDictionary dictionaryWithDictionary:r[i]];
            reference[@"author"] = [reference[@"author"] capitalizedString];
            
            NSArray *parts = [reference[@"timestamp"] componentsSeparatedByString:@" "];
            if (parts.count > 5){
                NSString *month = parts[1];
                NSString *day = parts[2];
                NSString *year = [parts lastObject];
                
                if ([day hasPrefix:@"0"])
                    day = [day stringByReplacingOccurrencesOfString:@"0" withString:@""];
                
                reference[@"formattedDate"] = [NSString stringWithFormat:@"%@ %@, %@", month, day, year];
            }
            
            [references addObject:reference];
        }
        
        if (self.publicProfile)
            self.publicProfile.references = references;
        else
            self.profile.references = references;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (r.count==0){
                NSString *msg = nil;
                if (self.publicProfile){
                    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [self.publicProfile.firstName capitalizedString], [self.publicProfile.lastName capitalizedString]];
                    msg = [NSString stringWithFormat:@"%@ has no references.", fullName];
                }
                else{
                    msg = @"You have no references. References are a great way to show potential employers that you have a solid trackrecord and work history.\n\nTo request a reference, tap the 'Request References' button.";
                }
                
                [self showNotification:@"No References" withMessage:msg];
                return;
            }
            
            [self.referencesTable reloadData];
            [self layoutReferencesTable];
            
        });
    }];
}

- (void)layoutReferencesTable
{
    [UIView animateWithDuration:1.50f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.referencesTable.frame;
                         frame.origin.y = 0.0f;
                         self.referencesTable.frame = frame;
                     }
                     completion:NULL];
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addReference:(UIBarButtonItem *)btn
{
    NSLog(@"addReference: ");
    if (self.publicProfile){
        
        
        return;
    }
    
    
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:[[MQContactsViewController alloc] init]];
    navCtr.navigationBar.barTintColor = kOrange;
    [self presentViewController:navCtr animated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.publicProfile) ? self.publicProfile.references.count : self.profile.references.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    MQReferenceCell *cell = (MQReferenceCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil)
        cell = [[MQReferenceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    NSDictionary *reference = (self.publicProfile) ? (NSDictionary *)self.publicProfile.references[indexPath.row] : (NSDictionary *)self.profile.references[indexPath.row];
    cell.lblText.text = reference[@"text"];
    cell.lblDate.text = reference[@"formattedDate"];
    cell.lblFrom.text = reference[@"author"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *reference = (self.publicProfile) ? (NSDictionary *)self.publicProfile.references[indexPath.row] : (NSDictionary *)self.profile.references[indexPath.row];
    
    CGRect boundingRect = [reference[@"text"] boundingRectWithSize:CGSizeMake([MQReferenceCell textLabelWidth], 250.0f)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[MQReferenceCell textLabelFont]}
                                                           context:nil];
    
    return boundingRect.size.height+52.0f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
