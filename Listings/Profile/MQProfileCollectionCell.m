//
//  MQProfileCollectionCell.m
//  Listings
//
//  Created by Dan Kwon on 10/29/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQProfileCollectionCell.h"
#import "Config.h"

@interface MQProfileCollectionCell ()
@property (strong, nonatomic) UIView *base;
@end

@implementation MQProfileCollectionCell
@synthesize icon;
@synthesize lblName;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, frame.size.width-4.0f, frame.size.height-4.0f)];
        self.base.backgroundColor = [UIColor greenColor];
        self.base.layer.cornerRadius = 3.0f;
        self.base.layer.masksToBounds = YES;
        
        CGFloat dimen = 54.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
        self.icon.center = CGPointMake(0.50f*frame.size.width, 0.25f*frame.size.height);
        self.icon.backgroundColor = [UIColor lightGrayColor];
        self.icon.layer.borderWidth = 2.0f;
        self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.icon.layer.cornerRadius = 0.50f*dimen;
        self.icon.layer.masksToBounds = YES;
        [self.base addSubview:self.icon];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, self.base.frame.size.width-24.0f, 18.0f)];
//        [self.lblName addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblName.textAlignment = NSTextAlignmentLeft;
        self.lblName.textColor = [UIColor darkGrayColor];
        self.lblName.numberOfLines = 0;
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];

        [self.base addSubview:self.lblName];
        
        [self.contentView addSubview:self.base];

    }
    
    return self;
    
}




@end
