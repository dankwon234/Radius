//
//  MQNotificationView.m
//  Listings
//
//  Created by Dan Kwon on 11/6/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQNotificationView.h"

@interface MQNotificationView ()
@property (strong, nonatomic) UIView *background;
@end

@implementation MQNotificationView
@synthesize lblTitle;
@synthesize lblMessage;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        CGFloat padding = 24.0f;
        self.background = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, 0.6f*frame.size.height)];
        self.background.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.background.backgroundColor = [UIColor whiteColor];
        self.background.alpha = 0.86f;
        self.background.layer.cornerRadius = 3.0f;
        self.background.layer.masksToBounds = YES;
        self.background.layer.borderColor = [[UIColor grayColor] CGColor];
        self.background.layer.borderWidth = 0.5f;
        [self addSubview:self.background];
        
        UIImageView *exclamation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamation.png"]];
        exclamation.center = CGPointMake(self.background.center.x, self.background.center.y+60.0f);
        exclamation.alpha = 0.35f;
        [self addSubview:exclamation];
        
        CGFloat y = padding+8.0f;
        CGFloat x = y;
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        logo.frame = CGRectMake(x, y, 0.18f*logo.frame.size.width, 0.18f*logo.frame.size.height);
        [self addSubview:logo];
        
        x = logo.frame.origin.x+logo.frame.size.width+10.0f;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.background.frame.size.width-x, 22.0)];
        self.lblTitle.center = CGPointMake(self.lblTitle.center.x, logo.center.y);
        self.lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.text = @"Alert Title";
        [self addSubview:self.lblTitle];
        
        y = logo.frame.origin.y+logo.frame.size.height+8.0f;
        x = padding+8.0f;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*padding-16.0f, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        
        y += 12.0f;
        self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*x, 16.0f)];
        self.lblMessage.textColor = [UIColor darkGrayColor];
        self.lblMessage.numberOfLines = 0;
        self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblMessage.text = @"This is the message";
        self.lblMessage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
        [self.lblMessage addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblMessage];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.lblMessage removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"])
        return;
    
    CGRect frame = self.lblMessage.frame;
    CGRect boundingRect = [self.lblMessage.text boundingRectWithSize:CGSizeMake(frame.size.width, 300.0f)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.lblMessage.font}
                                                             context:nil];
    
    frame.size.height = boundingRect.size.height;
    self.lblMessage.frame = frame;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
