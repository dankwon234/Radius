//
//  MQReferenceCell.h
//  Listings
//
//  Created by Dan Kwon on 11/3/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQReferenceCell : UITableViewCell

@property (strong, nonatomic) UIView *base;
@property (strong, nonatomic) UILabel *lblText;
@property (strong, nonatomic) UILabel *lblFrom;
@property (strong, nonatomic) UILabel *lblDate;
+ (CGFloat)textLabelWidth;
+ (UIFont *)textLabelFont;
@end
