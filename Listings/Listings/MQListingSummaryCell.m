//
//  MQListingSummaryCell.m
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQListingSummaryCell.h"
#import "Config.h"

@implementation MQListingSummaryCell
@synthesize base;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        self.contentView.backgroundColor = kBaseGray;
        self.base = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 0.0f, frame.size.width-10.0f, kHeaderCellHeight-5.0f)];
        self.base.backgroundColor = [UIColor whiteColor];
        
        
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
