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

@end

@implementation MQProfileCollectionCell
@synthesize base;
@synthesize backgroundImage;
@synthesize icon;
@synthesize lblName;
@synthesize lblLocation;
@synthesize lblSkills;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, frame.size.width-4.0f, frame.size.height-4.0f)];
        self.base.backgroundColor = [UIColor whiteColor];
        self.base.layer.cornerRadius = 3.0f;
        self.base.layer.masksToBounds = YES;
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.base.frame.size.width, self.base.frame.size.width)];
        self.backgroundImage.alpha = 0;
        [self.backgroundImage addObserver:self forKeyPath:@"image" options:0 context:nil];
        [self.base addSubview:self.backgroundImage];
        
        CGFloat y = 0.25f*frame.size.height;
        CGRect baseFrame = self.base.frame;
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, baseFrame.size.width, baseFrame.size.height-y)];
        bottom.backgroundColor = kBaseGray;
        
        UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
        shadow.frame = CGRectMake(0.0f, 0.0f, baseFrame.size.width, 0.75f*shadow.frame.size.height);
        [bottom addSubview:shadow];
        
        [self.base addSubview:bottom];
        
        CGFloat dimen = 54.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
        self.icon.center = CGPointMake(0.50f*frame.size.width, y-10.0f);
        self.icon.backgroundColor = [UIColor lightGrayColor];
        self.icon.layer.borderWidth = 2.0f;
        self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.icon.layer.cornerRadius = 0.50f*dimen;
        self.icon.layer.masksToBounds = YES;
        [self.base addSubview:self.icon];
        y = self.icon.frame.origin.y+self.icon.frame.size.height+2.0f;
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, y, baseFrame.size.width-24.0f, 18.0f)];
//        [self.lblName addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblName.textAlignment = NSTextAlignmentCenter;
        self.lblName.textColor = [UIColor darkGrayColor];
        self.lblName.numberOfLines = 0;
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
        [self.base addSubview:self.lblName];
        y += self.lblName.frame.size.height+4.0f;
        
        self.lblSkills = [[UILabel alloc] initWithFrame:CGRectMake(10, y, baseFrame.size.width-20.0f, 14)];
        self.lblSkills.textAlignment = NSTextAlignmentCenter;
        self.lblSkills.textColor = [UIColor grayColor];
        self.lblSkills.font = [UIFont systemFontOfSize:9];
        self.lblSkills.backgroundColor = [UIColor whiteColor];
        self.lblSkills.numberOfLines = 0;
        self.lblSkills.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblSkills.layer.borderWidth = 0.5f;
        self.lblSkills.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.lblSkills.layer.cornerRadius = 2.0f;
        self.lblSkills.layer.masksToBounds = YES;
        [self.lblSkills addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.base addSubview:self.lblSkills];

        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, baseFrame.size.height-24.0f, baseFrame.size.width, 0.5f)];
        line.backgroundColor = [UIColor grayColor];
        [self.base addSubview:line];
        
        self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, baseFrame.size.height-18.0f, baseFrame.size.width-24.0f, 12.0f)];
        self.lblLocation.textAlignment = NSTextAlignmentCenter;
        self.lblLocation.textColor = [UIColor darkGrayColor];
        self.lblLocation.backgroundColor = [UIColor clearColor];
        self.lblLocation.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
        [self.base addSubview:self.lblLocation];

        
        [self.contentView addSubview:self.base];

    }
    
    return self;
}

- (void)dealloc
{
    [self.lblSkills removeObserver:self forKeyPath:@"text"];
    [self.backgroundImage removeObserver:self forKeyPath:@"image"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]){
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.backgroundImage.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             
                         }];

    }
    
    if ([keyPath isEqualToString:@"text"]){
        CGRect frame = self.lblSkills.frame;
        CGRect boudingRect = [self.lblSkills.text boundingRectWithSize:CGSizeMake(frame.size.width, 250.0f)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:self.lblSkills.font}
                                                               context:NULL];
        
        frame.size.height = boudingRect.size.height+4.0f;
        self.lblSkills.frame = frame;
        return;
    }
    
    
    
    
}




@end
