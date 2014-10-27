//
//  MQSearchLocationCell.m
//  Listings
//
//  Created by Dan Kwon on 10/26/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQSearchLocationCell.h"

@implementation MQSearchLocationCell
@synthesize btnRemove;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 0.5f)];
        separator.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:separator];
        
        self.btnRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnRemove.frame = CGRectMake(frame.size.width-44.0f, 0, 44.0f, 44.0f);
        [self.btnRemove setBackgroundImage:[UIImage imageNamed:@"iconDeleteRed.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.btnRemove];
    }
    
    return self;
}

- (void)awakeFromNib
{

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
