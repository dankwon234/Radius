//
//  MQListingHeaderCell.m
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQListingHeaderCell.h"
#import "Config.h"

@implementation MQListingHeaderCell
@synthesize base;
@synthesize lblHeader;
@synthesize lblLocation;
@synthesize lblApplications;
@synthesize lblDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        self.contentView.backgroundColor = kBaseGray;
        self.base = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, frame.size.width-10.0f, kHeaderCellHeight-10.0f)];
        CGFloat rgbMax = 255.0f;
        self.base.backgroundColor = [UIColor colorWithRed:156.0f/rgbMax green:211.0f/rgbMax blue:179.0f/rgbMax alpha:1.0f];
        
        self.lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 4.0f, frame.size.width-40.0f, 26.0f)];
        self.lblHeader.backgroundColor = [UIColor clearColor];
        self.lblHeader.textAlignment = NSTextAlignmentCenter;
        self.lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0f];
        self.lblHeader.textColor = [UIColor darkGrayColor];
        self.lblHeader.numberOfLines = 0;
        self.lblHeader.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblHeader.shadowColor = [UIColor whiteColor];
        self.lblHeader.shadowOffset = CGSizeMake(-0.5f, 0.5f);
        [self.base addSubview:self.lblHeader];
        
        
        UIImageView *iconLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconLocation.png"]];
        iconLocation.center = CGPointMake(0.20f*frame.size.width, 80.0f);
        [self.base addSubview:iconLocation];
        
        CGFloat lblWidth = 1.5f*iconLocation.frame.size.width;
        UIFont *lblFont = [UIFont systemFontOfSize:10.0f];
        UIColor *lblColor = [UIColor blueColor];

        
        CGFloat y = iconLocation.frame.origin.y+iconLocation.frame.size.height+4.0f;
        self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, y, lblWidth, 24.0f)];
        self.lblLocation.center = CGPointMake(iconLocation.center.x, self.lblLocation.center.y);
        self.lblLocation.numberOfLines = 2;
        self.lblLocation.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblLocation.textAlignment = NSTextAlignmentCenter;
        self.lblLocation.textColor = lblColor;
        self.lblLocation.font = lblFont;
        [self.base addSubview:self.lblLocation];


        UIImageView *iconCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCheck.png"]];
        iconCheck.center = CGPointMake(0.50f*frame.size.width, iconLocation.center.y);
        [self.base addSubview:iconCheck];
        
        self.lblApplications = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lblWidth, 24.0f)];
        self.lblApplications.center = CGPointMake(iconCheck.center.x, self.lblLocation.center.y);
        self.lblApplications.numberOfLines = 2;
        self.lblApplications.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblApplications.textAlignment = NSTextAlignmentCenter;
        self.lblApplications.textColor = lblColor;
        self.lblApplications.font = lblFont;
        [self.base addSubview:self.lblApplications];

        
        UIImageView *iconCalendar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCalendar.png"]];
        iconCalendar.center = CGPointMake(0.80f*frame.size.width, iconLocation.center.y);
        [self.base addSubview:iconCalendar];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lblWidth, 24.0f)];
        self.lblDate.center = CGPointMake(iconCalendar.center.x, self.lblLocation.center.y);
        self.lblDate.numberOfLines = 2;
        self.lblDate.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblDate.textAlignment = NSTextAlignmentCenter;
        self.lblDate.textColor = lblColor;
        self.lblDate.font = lblFont;
        [self.base addSubview:self.lblDate];

        [self.contentView addSubview:self.base];


    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
