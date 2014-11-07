//
//  MQNotificationView.m
//  Listings
//
//  Created by Dan Kwon on 11/6/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQNotificationView.h"
#import "Config.h"

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
        
        UIView *bgBlack = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        bgBlack.backgroundColor = [UIColor blackColor];
        bgBlack.alpha = 0.8f;
        [self addSubview:bgBlack];
        
        CGFloat padding = 24.0f;
        self.background = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, 0.70f*frame.size.height)];
        self.background.backgroundColor = [UIColor whiteColor];
        self.background.alpha = 0.86f;
        self.background.layer.cornerRadius = 3.0f;
        self.background.layer.masksToBounds = YES;
        self.background.layer.borderColor = [[UIColor grayColor] CGColor];
        self.background.layer.borderWidth = 0.5f;
        [self addSubview:self.background];
        
        UIImageView *exclamation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamation.png"]];
        exclamation.center = CGPointMake(self.background.center.x, self.background.center.y+60.0f);
        exclamation.alpha = 0.25f;
        [self addSubview:exclamation];
        
        CGFloat y = padding+8.0f;
        CGFloat x = y;
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        logo.frame = CGRectMake(x, y, 0.18f*logo.frame.size.width, 0.18f*logo.frame.size.height);
        [self addSubview:logo];
        
        x = padding+8.0f;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.background.frame.size.width-x, 22.0)];
        self.lblTitle.center = CGPointMake(self.lblTitle.center.x, logo.center.y);
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.text = @"Alert Title";
        [self addSubview:self.lblTitle];
        
        y = logo.frame.origin.y+logo.frame.size.height+8.0f;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*padding-16.0f, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        
        y += 16.0f;
        x *= 2;
        self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*x, 16.0f)];
        self.lblMessage.textColor = [UIColor darkGrayColor];
        self.lblMessage.numberOfLines = 0;
        self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblMessage.textAlignment = NSTextAlignmentCenter;
        self.lblMessage.text = @"This is the message";
        self.lblMessage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
        [self.lblMessage addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblMessage];
        
        y = self.background.frame.origin.y + self.background.frame.size.height+24.0f;
        UIButton *btnDismiss = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDismiss.frame = CGRectMake(padding, y, frame.size.width-2*padding, 44.0f);
        btnDismiss.backgroundColor = kOrange;
        btnDismiss.layer.cornerRadius = 3.0f;
        btnDismiss.layer.masksToBounds = YES;
        [btnDismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnDismiss setTitle:@"DISMISS" forState:UIControlStateNormal];
        btnDismiss.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        [btnDismiss addTarget:self action:@selector(dismissButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnDismiss];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.lblMessage removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    CGRect frame = self.lblMessage.frame;
    CGRect boundingRect = [self.lblMessage.text boundingRectWithSize:CGSizeMake(frame.size.width, 300.0f)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.lblMessage.font}
                                                             context:nil];
    
    frame.size.height = boundingRect.size.height;
    self.lblMessage.frame = frame;
}

- (void)dismissButton:(UIButton *)btn
{
    
    [UIView animateWithDuration:0.35f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y = -frame.size.height;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished){
                         CGRect frame = self.frame;
                         frame.origin.y = frame.size.height;
                         self.frame = frame;
                         
                         self.alpha = 0.0f;
                     }];

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
