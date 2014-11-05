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
    
    self.referencesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.referencesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.referencesTable.dataSource = self;
    self.referencesTable.delegate = self;
    self.referencesTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.referencesTable.backgroundColor = [UIColor clearColor];
    [view addSubview:self.referencesTable];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addReference:)];
    
    if (self.profile.references)
        return;
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] fetchReferences:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSArray *r = results[@"references"];
        self.profile.references = [NSMutableArray array];
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

            [self.profile.references addObject:reference];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.referencesTable reloadData];
        });
    }];

}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addReference:(UIBarButtonItem *)btn
{
    NSLog(@"addReference: ");
    MQContactsViewController *contactsVc = [[MQContactsViewController alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:contactsVc];
    navCtr.navigationBar.barTintColor = kOrange;
    [self presentViewController:navCtr animated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.references.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    MQReferenceCell *cell = (MQReferenceCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil)
        cell = [[MQReferenceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    NSDictionary *reference = (NSDictionary *)self.profile.references[indexPath.row];
    cell.lblText.text = reference[@"text"];
    cell.lblDate.text = reference[@"formattedDate"];
    cell.lblFrom.text = reference[@"author"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *reference = (NSDictionary *)self.profile.references[indexPath.row];
    CGRect boundingRect = [reference[@"text"] boundingRectWithSize:CGSizeMake([MQReferenceCell textLabelWidth], 250.0f)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[MQReferenceCell textLabelFont]}
                                                           context:nil];
    
    return boundingRect.size.height+44.0f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end