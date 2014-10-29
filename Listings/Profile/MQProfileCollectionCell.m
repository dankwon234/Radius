//
//  MQProfileCollectionCell.m
//  Listings
//
//  Created by Dan Kwon on 10/29/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQProfileCollectionCell.h"
#import "Config.h"

@implementation MQProfileCollectionCell
@synthesize icon;
@synthesize lblName;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, 18.0f)];
//        [self.lblName addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblName.textAlignment = NSTextAlignmentLeft;
        self.lblName.textColor = [UIColor darkGrayColor];
        self.lblName.numberOfLines = 0;
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];

        self.contentView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.lblName];

    }
    
    return self;
    
}




@end
