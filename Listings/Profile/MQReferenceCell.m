//
//  MQReferenceCell.m
//  Listings
//
//  Created by Dan Kwon on 11/3/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQReferenceCell.h"
#import "Config.h"

#define kPadding            12.0f
#define kTextLabelIndent    80.0f
#define kTextLabelFont      [UIFont fontWithName:@"Heiti SC" size:12.0f]

@implementation MQReferenceCell
@synthesize base;
@synthesize lblText;
@synthesize lblFrom;
@synthesize lblDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(kTextLabelIndent, kPadding, frame.size.width-kPadding-kTextLabelIndent, 32.0f)];
        self.base.backgroundColor = [UIColor whiteColor];
        self.base.alpha = 0.86f;
        self.base.layer.cornerRadius = 3.0f;
        self.base.layer.masksToBounds = YES;
        [self.contentView addSubview:self.base];
        
        CGFloat dimen = kTextLabelIndent-30.0f;
        self.lblFrom = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 12.0f, dimen, dimen)];
        self.lblFrom.backgroundColor = kOrange;
        self.lblFrom.layer.cornerRadius = 0.5f*dimen;
        self.lblFrom.layer.masksToBounds = YES;
        self.lblFrom.layer.borderWidth = 2.0f;
        self.lblFrom.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.lblFrom.textColor = [UIColor whiteColor];
        self.lblFrom.font = [UIFont boldSystemFontOfSize:10.0f];
        self.lblFrom.numberOfLines = 2;
        self.lblFrom.textAlignment = NSTextAlignmentCenter;
        self.lblFrom.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblFrom.text = @"Denny\nKwon";
        [self.contentView addSubview:self.lblFrom];
        
        CGFloat x = kTextLabelIndent+kPadding;
        self.lblText = [[UILabel alloc] initWithFrame:CGRectMake(x, 2*kPadding, self.base.frame.size.width-2*kPadding, 32.0f)];
        self.lblText.textColor = [UIColor darkGrayColor];
        self.lblText.numberOfLines = 0;
        self.lblText.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblText.font = kTextLabelFont;
        [self.lblText addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.contentView addSubview:self.lblText];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.lblText.frame.size.width, 12.0f)];
        self.lblDate.backgroundColor = [UIColor clearColor];
        self.lblDate.textAlignment = NSTextAlignmentRight;
        self.lblDate.textColor = kGreen;
        self.lblDate.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:self.lblDate];

    }
    
    return self;
}

- (void)dealloc
{
    [self.lblText removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    CGRect frame = self.lblText.frame;
    CGRect boundingRect = [self.lblText.text boundingRectWithSize:CGSizeMake(frame.size.width, 250.0f)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblText.font}
                                                          context:nil];
    
    frame.size.height = boundingRect.size.height;
    self.lblText.frame = frame;
    
    frame = self.lblDate.frame;
    frame.origin.y = self.lblText.frame.origin.y+self.lblText.frame.size.height+6.0f;
    self.lblDate.frame = frame;

    frame = self.base.frame;
    frame.size.height = boundingRect.size.height+32.0f;
    self.base.frame = frame;
    
}

+ (CGFloat)textLabelWidth
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGFloat width = frame.size.width-kTextLabelIndent-3*kPadding;
    return width;
}

+ (UIFont *)textLabelFont
{
    return kTextLabelFont;
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
