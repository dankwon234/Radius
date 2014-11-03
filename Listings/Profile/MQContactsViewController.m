//
//  MQContactsViewController.m
//  Listings
//
//  Created by Dan Kwon on 11/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MQSearchLocationCell.h"
#import "MQWebServices.h"


@interface MQContactsViewController ()
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) UITableView *contactsTable;
@end

@implementation MQContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Contacts";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.contacts = [NSMutableArray array];
        self.selectedContacts = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgLegsBlue.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    self.contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.contactsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.contactsTable.dataSource = self;
    self.contactsTable.delegate = self;
    self.contactsTable.contentInset = UIEdgeInsetsMake(0, 0, 64.0f, 0);
    self.contactsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.contactsTable.alpha = 0.90f;
    [view addSubview:self.contactsTable];
    
    UIView *requestView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    requestView.backgroundColor = [UIColor grayColor];
    requestView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnRequest = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRequest.frame = CGRectMake(12.0, 12.0f, frame.size.width-24.0f, 44.0f);
    btnRequest.backgroundColor = [UIColor clearColor];
    btnRequest.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnRequest.layer.borderWidth = 1.5f;
    btnRequest.layer.cornerRadius = 4.0f;
    btnRequest.layer.masksToBounds = YES;
    btnRequest.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnRequest setTitle:@"REQUEST REFERENCES" forState:UIControlStateNormal];
    [btnRequest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRequest addTarget:self action:@selector(requestReferences) forControlEvents:UIControlEventTouchUpInside];
    [requestView addSubview:btnRequest];
    
    [view addSubview:requestView];


    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImage *imgExit = [UIImage imageNamed:@"exit.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.7f*imgExit.size.width, 0.7f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];


    [self requestAddresBookAccess];
}

- (void)exit:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)requestReferences
{
    NSLog(@"requestReferences: %@", [self.selectedContacts description]);
    if (self.selectedContacts.count==0){
        [self showAlertWithtTitle:@"No Requests" message:@"Please include at least one contact for a reference."];
        return;
    }
    
    [self.loadingIndicator startLoading];
    [[MQWebServices sharedInstance] requestReferences:self.selectedContacts forProfile:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self showAlertWithtTitle:@"Referece Requests Submitted" message:@"Your reference requests have been submitted. Each person you specified will receive a text message asking for a reference on your behalf."];
            }];
        });
    }];
}

//search for beginning of first or last name, have search work for only prefixes
- (void)requestAddresBookAccess//call to get address book, latency
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        NSLog(@"Address book error");
        [self showAlertWithtTitle:@"Error" message:@""];
        return;
    }
    
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        if (!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Address book access denied");
                [self showAlertWithtTitle:@"Contact List Unauthorized" message:@"Please go to the settings app and allow Radius to access your address book to request references."];
                return;
            });
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Address book access granted");
            [self parseContactsList:addressBook];
        });
    });
}

- (void)parseContactsList:(ABAddressBookRef)addressBook
{
//    NSLog(@"Address book access granted");
    NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for( int i=0; i<allContacts.count; i++) {
        ABRecordRef contact = (__bridge ABRecordRef)allContacts[i];
        
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
        
        // phone:
        ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        NSString *phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
        
        BOOL enoughInfo = NO;
        if (firstName != nil && phoneNumber != nil)
            enoughInfo = YES;
        
        if (enoughInfo==NO)
            continue;
        
        
        NSMutableDictionary *contactInfo = [NSMutableDictionary dictionary];
        contactInfo[@"firstName"] = firstName;
        
        NSString *formattedNumber = @"";
        static NSString *numbers = @"0123456789";
        for (int i=0; i<phoneNumber.length; i++) {
            NSString *character = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
            if ([numbers rangeOfString:character].location != NSNotFound){
                formattedNumber = [formattedNumber stringByAppendingString:character];
                
                NSString *firstNum = [formattedNumber substringWithRange:NSMakeRange(0, 1)];
                if ([firstNum isEqualToString:@"1"])
                    formattedNumber = [formattedNumber substringFromIndex:1];
            }
        }
        
        contactInfo[@"phoneNumber"] = formattedNumber;
        
        // email:
        ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
        if (email)
            contactInfo[@"email"] = email;
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
        if (lastName){
            contactInfo[@"lastName"] = lastName;
            contactInfo[@"fullName"] = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        else{
            contactInfo[@"fullName"] = firstName;
        }
        
        [self.contacts addObject:contactInfo];
    }
    
    [self.contacts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
    
    [self.loadingIndicator stopLoading];
    CFRelease(addressBook);
    [self.contactsTable reloadData];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    MQSearchLocationCell *cell = (MQSearchLocationCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[MQSearchLocationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [cell.btnRemove setBackgroundImage:[UIImage imageNamed:@"iconSelected.png"] forState:UIControlStateNormal];
    }
    
    NSDictionary *contactInfo = (NSDictionary *)self.contacts[indexPath.row];
    cell.textLabel.text = contactInfo[@"fullName"];
    cell.textLabel.textColor = ([self.selectedContacts containsObject:contactInfo]) ? kGreen : [UIColor darkGrayColor];
    if ([self.selectedContacts containsObject:contactInfo]){
        cell.textLabel.textColor = kGreen;
        cell.btnRemove.alpha = 1.0f;
    }
    else{
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.btnRemove.alpha = 0.0f;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *contactInfo = (NSDictionary *)self.contacts[indexPath.row];
    if ([self.selectedContacts containsObject:contactInfo])
        [self.selectedContacts removeObject:contactInfo];
    else
        [self.selectedContacts addObject:contactInfo];
    
    
    [self.contactsTable reloadData];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
