//
//  MQTutorialCard.m
//  Listings
//
//  Created by Dan Kwon on 11/8/14.
//  Copyright (c) 2014 Mercury. All rights reserved.


#import "MQTutorialCard.h"

@implementation MQTutorialCard
@synthesize lblTitle;
@synthesize lblDescription;
@synthesize backgroundImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
        
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.7f*width, 0.7f*height)];
        NSLog(@"WIDTH: %.2f", card.frame.size.width);
        card.backgroundColor = [UIColor whiteColor];
        card.layer.cornerRadius = 3.0f;
        card.layer.masksToBounds = YES;
        card.center = CGPointMake(0.5f*width, 0.5f*height);
        
        
        double scale = 0.5f;
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shot1.png"]];
        self.backgroundImage.frame = CGRectMake(0.0f, 0.6f*card.frame.size.height, scale*self.backgroundImage.frame.size.width, scale*self.backgroundImage.frame.size.height);
        self.backgroundImage.center = CGPointMake(0.5f*card.frame.size.width, self.backgroundImage.center.y);
        [card addSubview:self.backgroundImage];


        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        logo.frame = CGRectMake(10.0f, 10.0f, 0.18f*logo.frame.size.width, 0.18f*logo.frame.size.height);
        [card addSubview:logo];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, 0.0f, card.frame.size.width-24.0f, 22.0f)];
        self.lblTitle.center = CGPointMake(self.lblTitle.center.x, logo.center.y);
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.text = @"TITLE";
        [card addSubview:self.lblTitle];
        
        CGFloat y = logo.frame.origin.y+logo.frame.size.height+8.0f;
        CGFloat padding = 12.0f;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(padding, y, card.frame.size.width-2*padding, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [card addSubview:line];
        y += 16.0f;
        
        self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, card.frame.size.width-2*padding, 22.0f)];
        self.lblDescription.textAlignment = NSTextAlignmentCenter;
        self.lblDescription.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
        self.lblDescription.textColor = [UIColor darkGrayColor];
        self.lblDescription.text = @"Description";
        self.lblDescription.numberOfLines = 0;
        self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
        [self.lblDescription addObserver:self forKeyPath:@"text" options:0 context:nil];
        [card addSubview:self.lblDescription];
//        y += 84.0f;
        
        

        
        [self addSubview:card];

    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    [self.lblDescription sizeToFit];
}

- (void)dealloc
{
    [self.lblDescription removeObserver:self forKeyPath:@"text"];
}



@end
