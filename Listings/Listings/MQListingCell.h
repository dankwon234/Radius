//
//  MQListingCell.h
//  Listings
//
//  Created by Dan Kwon on 9/6/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQListingCell : UICollectionViewCell


@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UIView *base;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblVenue;
@property (strong, nonatomic) UILabel *lblLocation;
@property (nonatomic) BOOL isRotated;
- (void)rotateContentView;
- (void)restore;
@end
