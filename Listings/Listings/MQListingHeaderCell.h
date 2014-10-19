//
//  MQListingHeaderCell.h
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQListingHeaderCell : UITableViewCell

@property (strong, nonatomic) UIView *base;
@property (strong, nonatomic) UILabel *lblHeader;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UILabel *lblApplications;
@property (strong, nonatomic) UILabel *lblDate;
@end
