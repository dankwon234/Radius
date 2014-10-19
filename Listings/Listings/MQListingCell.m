//
//  MQListingCell.m
//  Listings
//
//  Created by Dan Kwon on 9/6/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQListingCell.h"
#import "Config.h"


@implementation MQListingCell
@synthesize icon;
@synthesize base;
@synthesize lblTitle;
@synthesize lblDate;
@synthesize lblVenue;
@synthesize lblLocation;
@synthesize isRotated;

#define kAnimationDuration 0.24f

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isRotated = NO;
        self.contentView.layer.cornerRadius = 2.0f;
        self.contentView.layer.masksToBounds = YES;
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.base.layer.cornerRadius = 2.0f;
        self.base.backgroundColor = [UIColor clearColor];
        self.base.layer.masksToBounds = YES;
        
        CGFloat dimen = 50.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(44.0f, 40.0f, dimen, dimen)];
        self.icon.layer.cornerRadius = 0.5f*dimen;
        self.icon.layer.masksToBounds = YES;
        self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.icon.layer.borderWidth = 1.0f;
        self.icon.backgroundColor = [UIColor whiteColor];
        [self.base addSubview:self.icon];

        UIColor *darkGray = [UIColor darkGrayColor];
        UIColor *clear = [UIColor clearColor];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40, 18.0f)];
        self.lblDate.center = CGPointMake(self.lblDate.center.x, self.icon.center.y);
        self.lblDate.backgroundColor = clear;
        self.lblDate.textAlignment = NSTextAlignmentLeft;
        self.lblDate.textColor = darkGray;
        self.lblDate.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
        self.lblDate.text = @"Oct 12";
        [self.base addSubview:self.lblDate];
        
        
        CGFloat y = 42.0f;
        CGFloat x = self.icon.frame.origin.x+dimen+6.0f;
        CGFloat width = frame.size.width-x;

        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 18.0f)];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = darkGray;
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.backgroundColor = clear;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblVenue = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
        self.lblVenue.textAlignment = NSTextAlignmentLeft;
        self.lblVenue.textColor = darkGray;
        self.lblVenue.backgroundColor = clear;
        self.lblVenue.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
        [self.base addSubview:self.lblVenue];
        y += self.lblVenue.frame.size.height;

        self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
        self.lblLocation.textAlignment = NSTextAlignmentLeft;
        self.lblLocation.textColor = darkGray;
        self.lblLocation.backgroundColor = clear;
        self.lblLocation.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
        [self.base addSubview:self.lblLocation];

        
        [self.contentView addSubview:self.base];
        

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideCell:)
                                                     name:kHideCellNotification
                                                   object:nil];

    }
    return self;
}

- (void)dealloc
{
    [self.lblTitle removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    
    CGRect frame = self.lblTitle.frame;
    CGRect boudingRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(self.lblTitle.frame.size.width, 250.0f)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                    context:NULL];
    frame.size.height = boudingRect.size.height;
    self.lblTitle.frame = frame;
    
    CGFloat y = frame.origin.y+frame.size.height;
    frame = self.lblVenue.frame;
    frame.origin.y = y;
    self.lblVenue.frame = frame;
    y += frame.size.height;
    
    frame = self.lblLocation.frame;
    frame.origin.y = y;
    self.lblLocation.frame = frame;
}

- (void)rotateContentView
{
    if (self.isRotated==YES) // already rotated, ignore
        return;
    
    self.isRotated = YES;
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CATransform3D transform = CATransform3DIdentity;
                         transform.m24 = 1.0 / 1200.0f;
                         self.contentView.layer.transform = CATransform3DRotate(transform, 10.0f*(M_PI/180.0f), 0, 1, 0.0f);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void)restore
{
    if (self.isRotated==NO)
        return;
    
    self.isRotated = NO;

    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.layer.transform = CATransform3DIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];

    
}

- (void)hideCell:(NSNotification *)note
{
//    NSLog(@"HIDE CELL: %@", [note.userInfo description]);
    
    MQListingCell *sourceCell = (MQListingCell *)note.userInfo[@"source"];
    if ([sourceCell isEqual:self])
        return;
    
    self.contentView.alpha = 0.0f;
}




@end
