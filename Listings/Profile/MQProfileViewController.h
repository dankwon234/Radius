//
//  MQProfileViewController.h
//  Listings
//
//  Created by Dan Kwon on 10/13/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQViewController.h"
#import "MQSocialAccountsMgr.h"

@interface MQProfileViewController : MQViewController <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) MQSocialAccountsMgr *socialMgr;
@property (copy, nonatomic) NSString *currentSocialAccountUsername;
@end
