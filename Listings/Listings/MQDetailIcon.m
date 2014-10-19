//
//  MQDetailIcon.m
//  Listings
//
//  Created by Dan Kwon on 9/21/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQDetailIcon.h"

@implementation MQDetailIcon
@synthesize icon;
@synthesize lblDetail;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat iconDimen = 40.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, iconDimen, iconDimen)];
        self.icon.center = CGPointMake(0.5f*frame.size.width, icon.center.y);
        self.icon.layer.cornerRadius = 0.5f*iconDimen;
        self.icon.layer.masksToBounds = YES;
        self.icon.backgroundColor = [UIColor whiteColor];
        [self addSubview:icon];
        
        self.lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, iconDimen+5.0f, frame.size.width, 28.0f)];
        self.lblDetail.textColor = [UIColor whiteColor];
        self.lblDetail.textAlignment = NSTextAlignmentCenter;
        self.lblDetail.font = [UIFont fontWithName:@"Heiti SC" size:10.0f];
        self.lblDetail.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblDetail.numberOfLines = 2;
        [self.lblDetail addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblDetail];
        
    }
    return self;
}

- (void)dealloc
{
    [self.lblDetail removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    
    CGRect frame = self.lblDetail.frame;
    
    CGRect boudingRect = [self.lblDetail.text boundingRectWithSize:CGSizeMake(frame.size.width, 450.0f)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:self.lblDetail.font}
                                                           context:NULL];
    
    frame.size.height = boudingRect.size.height;
    self.lblDetail.frame = frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
